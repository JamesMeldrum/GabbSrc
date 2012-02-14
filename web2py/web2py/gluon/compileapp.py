#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
This file is part of the web2py Web Framework
Copyrighted by Massimo Di Pierro <mdipierro@cs.depaul.edu>
License: LGPLv3 (http://www.gnu.org/licenses/lgpl.html)

Functions required to execute app components
============================================

FOR INTERNAL USE ONLY
"""

import re
import sys
import fnmatch
import os
import copy
import random
import __builtin__
from storage import Storage, List
from template import parse_template
from restricted import restricted, compile2
from fileutils import mktree, listdir, read_file, write_file
from myregex import regex_expose
from languages import translator
from dal import BaseAdapter, SQLDB, SQLField, DAL, Field
from sqlhtml import SQLFORM, SQLTABLE
from cache import Cache
from globals import current
import settings
from cfs import getcfs
import html
import validators
from http import HTTP, redirect
import marshal
import shutil
import imp
import logging
logger = logging.getLogger("web2py")
import rewrite

try:
    import py_compile
except:
    logger.warning('unable to import py_compile')

is_gae = settings.global_settings.web2py_runtime_gae
is_jython = settings.global_settings.is_jython = 'java' in sys.platform.lower() or hasattr(sys, 'JYTHON_JAR') or str(sys.copyright).find('Jython') > 0

TEST_CODE = \
    r"""
def _TEST():
    import doctest, sys, cStringIO, types, cgi, gluon.fileutils
    if not gluon.fileutils.check_credentials(request):
        raise HTTP(401, web2py_error='invalid credentials')
    stdout = sys.stdout
    html = '<h2>Testing controller "%s.py" ... done.</h2><br/>\n' \
        % request.controller
    for key in sorted([key for key in globals() if not key in __symbols__+['_TEST']]):
        eval_key = eval(key)
        if type(eval_key) == types.FunctionType:
            number_doctests = sum([len(ds.examples) for ds in doctest.DocTestFinder().find(eval_key)])
            if number_doctests>0:
                sys.stdout = cStringIO.StringIO()
                name = '%s/controllers/%s.py in %s.__doc__' \
                    % (request.folder, request.controller, key)
                doctest.run_docstring_examples(eval_key,
                    globals(), False, name=name)
                report = sys.stdout.getvalue().strip()
                if report:
                    pf = 'failed'
                else:
                    pf = 'passed'
                html += '<h3 class="%s">Function %s [%s]</h3>\n' \
                    % (pf, key, pf)
                if report:
                    html += CODE(report, language='web2py', \
                        link='/examples/global/vars/').xml()
                html += '<br/>\n'
            else:
                html += \
                    '<h3 class="nodoctests">Function %s [no doctests]</h3><br/>\n' \
                    % (key)
    response._vars = html
    sys.stdout = stdout
_TEST()
"""

class mybuiltin(object):
    """
    NOTE could simple use a dict and populate it,
    NOTE not sure if this changes things though if monkey patching import.....
    """
    #__builtins__
    def __getitem__(self, key):
        try:
            return getattr(__builtin__, key)
        except AttributeError:
            raise KeyError, key
    def __setitem__(self, key, value):
        setattr(self, key, value)

class LoadFactory(object):
    """
    Attention: this helper is new and experimental
    """
    def __init__(self,environment):
        self.environment = environment
    def __call__(self, c=None, f='index', args=None, vars=None,
                 extension=None, target=None,ajax=False,ajax_trap=False,
                 url=None,user_signature=False, content='loading...',**attr):
        if args is None: args = []
        vars = Storage(vars or {})
        import globals
        target = target or 'c'+str(random.random())[2:]
        attr['_id']=target
        request = self.environment['request']
        if '.' in f:
            f, extension = f.split('.',1)
        if url or ajax:
            url = url or html.URL(request.application, c, f, r=request,
                                  args=args, vars=vars, extension=extension,
                                  user_signature=user_signature)
            script = html.SCRIPT('web2py_component("%s","%s")' % (url, target),
                                 _type="text/javascript")
            return html.TAG[''](script, html.DIV(content,**attr))
        else:
            if not isinstance(args,(list,tuple)):
                args = [args]
            c = c or request.controller

            other_request = Storage()
            for key, value in request.items():
                other_request[key] = value
            other_request['env'] = Storage()
            for key, value in request.env.items():
                other_request.env['key'] = value
            other_request.controller = c
            other_request.function = f
            other_request.extension = extension or request.extension
            other_request.args = List(args)
            other_request.vars = vars
            other_request.get_vars = vars
            other_request.post_vars = Storage()
            other_response = globals.Response()
            other_request.env.path_info = '/' + \
                '/'.join([request.application,c,f] + \
                             map(str, other_request.args))
            other_request.env.query_string = \
                vars and html.URL(vars=vars).split('?')[1] or ''
            other_request.env.http_web2py_component_location = \
                request.env.path_info
            other_request.cid = target
            other_request.env.http_web2py_component_element = target
            other_response.view = '%s/%s.%s' % (c,f, other_request.extension)
            other_environment = copy.copy(self.environment)
            other_response._view_environment = other_environment
            other_response.generic_patterns = \
                copy.copy(current.response.generic_patterns)
            other_environment['request'] = other_request
            other_environment['response'] = other_response

            ## some magic here because current are thread-locals

            original_request, current.request = current.request, other_request
            original_response, current.response = current.response, other_response
            page = run_controller_in(c, f, other_environment)
            if isinstance(page, dict):
                other_response._vars = page
                for key in page:
                    other_response._view_environment[key] = page[key]
                run_view_in(other_response._view_environment)
                page = other_response.body.getvalue()
            current.request, current.response = original_request, original_response
            js = None
            if ajax_trap:
                link = html.URL(request.application, c, f, r=request,
                                args=args, vars=vars, extension=extension,
                                user_signature=user_signature)
                js = "web2py_trap_form('%s','%s');" % (link, target)
            script = js and html.SCRIPT(js,_type="text/javascript") or ''
            return html.TAG[''](html.DIV(html.XML(page),**attr),script)


def local_import_aux(name, force=False, app='welcome'):
    """
    In apps, instead of importing a local module
    (in applications/app/modules) with::

       import a.b.c as d

    you should do::

       d = local_import('a.b.c')

    or (to force a reload):

       d = local_import('a.b.c', reload=True)

    This prevents conflict between applications and un-necessary execs.
    It can be used to import any module, including regular Python modules.
    """
    items = name.replace('/','.')
    name = "applications.%s.modules.%s" % (app, items)
    module = __import__(name)
    for item in name.split(".")[1:]:
        module = getattr(module, item)
    if force:
        reload(module)
    return module


"""
OLD IMPLEMENTATION:
    items = name.replace('/','.').split('.')
    filename, modulepath = items[-1], os.path.join(apath,'modules',*items[:-1])
    imp.acquire_lock()
    try:
        file=None
        (file,path,desc) = imp.find_module(filename,[modulepath]+sys.path)
        if not path in sys.modules or reload:
            if is_gae:
                module={}
                execfile(path,{},module)
                module=Storage(module)
            else:
                module = imp.load_module(path,file,path,desc)
            sys.modules[path] = module
        else:
            module = sys.modules[path]
    except Exception, e:
        module = None
    if file:
        file.close()
    imp.release_lock()
    if not module:
        raise ImportError, "cannot find module %s in %s" % (filename, modulepath)
    return module
"""

def build_environment(request, response, session, store_current=True):
    """
    Build the environment dictionary into which web2py files are executed.
    """

    environment = {}
    for key in html.__all__:
        environment[key] = getattr(html, key)
    for key in validators.__all__:
        environment[key] = getattr(validators, key)
    if not request.env:
        request.env = Storage()

    t = environment['T'] = translator(request)
    c = environment['cache'] = Cache(request)
    if store_current:
        current.request = request
        current.response = response
        current.session = session
        current.T = t
        current.cache = c

    global __builtins__
    if is_jython: # jython hack
        __builtins__ = mybuiltin()
    else:
        __builtins__['__import__'] = __builtin__.__import__ ### WHY?
    environment['__builtins__'] = __builtins__
    environment['HTTP'] = HTTP
    environment['redirect'] = redirect
    environment['request'] = request
    environment['response'] = response
    environment['session'] = session
    environment['DAL'] = DAL
    environment['Field'] = Field
    environment['SQLDB'] = SQLDB        # for backward compatibility
    environment['SQLField'] = SQLField  # for backward compatibility
    environment['SQLFORM'] = SQLFORM
    environment['SQLTABLE'] = SQLTABLE
    environment['LOAD'] = LoadFactory(environment)
    environment['local_import'] = \
        lambda name, reload=False, app=request.application:\
        local_import_aux(name,reload,app)
    BaseAdapter.set_folder(os.path.join(request.folder, 'databases'))
    response._view_environment = copy.copy(environment)
    return environment


def save_pyc(filename):
    """
    Bytecode compiles the file `filename`
    """
    py_compile.compile(filename)


def read_pyc(filename):
    """
    Read the code inside a bytecode compiled file if the MAGIC number is
    compatible

    :returns: a code object
    """
    data = read_file(filename, 'rb')
    if not is_gae and data[:4] != imp.get_magic():
        raise SystemError, 'compiled code is incompatible'
    return marshal.loads(data[8:])


def compile_views(folder):
    """
    Compiles all the views in the application specified by `folder`
    """

    path = os.path.join(folder, 'views')
    for file in listdir(path, '^[\w/\-]+(\.\w+)+$'):
        data = parse_template(file, path)
        filename = ('views/%s.py' % file).replace('/', '_').replace('\\', '_')
        filename = os.path.join(folder, 'compiled', filename)
        write_file(filename, data)
        save_pyc(filename)
        os.unlink(filename)


def compile_models(folder):
    """
    Compiles all the models in the application specified by `folder`
    """

    path = os.path.join(folder, 'models')
    for file in listdir(path, '.+\.py$'):
        data = read_file(os.path.join(path, file))
        filename = os.path.join(folder, 'compiled','models',file)
        mktree(filename)
        write_file(filename, data)
        save_pyc(filename)
        os.unlink(filename)


def compile_controllers(folder):
    """
    Compiles all the controllers in the application specified by `folder`
    """

    path = os.path.join(folder, 'controllers')
    for file in listdir(path, '.+\.py$'):
        ### why is this here? save_pyc(os.path.join(path, file))
        data = read_file(os.path.join(path,file))
        exposed = regex_expose.findall(data)
        for function in exposed:
            command = data + "\nresponse._vars=response._caller(%s)\n" % \
                function
            filename = os.path.join(folder, 'compiled', ('controllers/'
                                     + file[:-3]).replace('/', '_')
                                     + '_' + function + '.py')
            write_file(filename, command)
            save_pyc(filename)
            os.unlink(filename)


def run_models_in(environment):
    """
    Runs all models (in the app specified by the current folder)
    It tries pre-compiled models first before compiling them.
    """

    folder = environment['request'].folder
    c = environment['request'].controller
    f = environment['request'].function
    cpath = os.path.join(folder, 'compiled')
    if os.path.exists(cpath):
        for model in listdir(cpath, '^models_\w+\.pyc$', 0):
            restricted(read_pyc(model), environment, layer=model)
        path = os.path.join(cpath, 'models')
        models = listdir(path, '^\w+\.pyc$',0,sort=False)
        compiled=True
    else:
        path = os.path.join(folder, 'models')
        models = listdir(path, '^\w+\.py$',0,sort=False)
        compiled=False
    paths = (path, os.path.join(path,c), os.path.join(path,c,f))
    for model in models:
        if not os.path.split(model)[0] in paths and c!='appadmin':
            continue
        elif compiled:
            code = read_pyc(model)
        elif is_gae:
            code = getcfs(model, model,
                          lambda: compile2(read_file(model), model))
        else:
            code = getcfs(model, model, None)
        restricted(code, environment, layer=model)


def run_controller_in(controller, function, environment):
    """
    Runs the controller.function() (for the app specified by
    the current folder).
    It tries pre-compiled controller_function.pyc first before compiling it.
    """

    # if compiled should run compiled!

    folder = environment['request'].folder
    path = os.path.join(folder, 'compiled')
    badc = 'invalid controller (%s/%s)' % (controller, function)
    badf = 'invalid function (%s/%s)' % (controller, function)
    if os.path.exists(path):
        filename = os.path.join(path, 'controllers_%s_%s.pyc'
                                 % (controller, function))
        if not os.path.exists(filename):
            raise HTTP(404,
                       rewrite.thread.routes.error_message % badf,
                       web2py_error=badf)
        restricted(read_pyc(filename), environment, layer=filename)
    elif function == '_TEST':
        # TESTING: adjust the path to include site packages
        from settings import global_settings
        from admin import abspath, add_path_first
        paths = (global_settings.gluon_parent, abspath('site-packages', gluon=True),  abspath('gluon', gluon=True), '')
        [add_path_first(path) for path in paths]
        # TESTING END

        filename = os.path.join(folder, 'controllers/%s.py'
                                 % controller)
        if not os.path.exists(filename):
            raise HTTP(404,
                       rewrite.thread.routes.error_message % badc,
                       web2py_error=badc)
        environment['__symbols__'] = environment.keys()
        code = read_file(filename)
        code += TEST_CODE
        restricted(code, environment, layer=filename)
    else:
        filename = os.path.join(folder, 'controllers/%s.py'
                                 % controller)
        if not os.path.exists(filename):
            raise HTTP(404,
                       rewrite.thread.routes.error_message % badc,
                       web2py_error=badc)
        code = read_file(filename)
        exposed = regex_expose.findall(code)
        if not function in exposed:
            raise HTTP(404,
                       rewrite.thread.routes.error_message % badf,
                       web2py_error=badf)
        code = "%s\nresponse._vars=response._caller(%s)\n" % (code, function)
        if is_gae:
            layer = filename + ':' + function
            code = getcfs(layer, filename,  lambda: compile2(code,layer))
        restricted(code, environment, filename)
    response = environment['response']
    vars=response._vars
    if response.postprocessing:
        for p in response.postprocessing:
            vars = p(vars)
    if isinstance(vars,unicode):
        vars = vars.encode('utf8')
    if hasattr(vars,'xml'):
        vars = vars.xml()
    return vars

def run_view_in(environment):
    """
    Executes the view for the requested action.
    The view is the one specified in `response.view` or determined by the url
    or `view/generic.extension`
    It tries the pre-compiled views_controller_function.pyc before compiling it.
    """

    request = environment['request']
    response = environment['response']
    folder = request.folder
    path = os.path.join(folder, 'compiled')
    badv = 'invalid view (%s)' % response.view
    patterns = response.generic_patterns or []
    regex = re.compile('|'.join(fnmatch.translate(r) for r in patterns))
    short_action =  '%(controller)s/%(function)s.%(extension)s' % request
    allow_generic = patterns and regex.search(short_action)
    if not isinstance(response.view, str):
        ccode = parse_template(response.view, os.path.join(folder, 'views'),
                               context=environment)
        restricted(ccode, environment, 'file stream')
    elif os.path.exists(path):
        x = response.view.replace('/', '_')
        files = ['views_%s.pyc' % x]
        if allow_generic:
            files.append('views_generic.%s.pyc' % request.extension)
        # for backward compatibility
        if request.extension == 'html':
            files.append('views_%s.pyc' % x[:-5])
            if allow_generic:
                files.append('views_generic.pyc')
        # end backward compatibility code
        for f in files:
            filename = os.path.join(path,f)
            if os.path.exists(filename):
                code = read_pyc(filename)
                restricted(code, environment, layer=filename)
                return
        raise HTTP(404,
                   rewrite.thread.routes.error_message % badv,
                   web2py_error=badv)
    else:
        filename = os.path.join(folder, 'views', response.view)
        if not os.path.exists(filename) and allow_generic:
            response.view = 'generic.' + request.extension
            filename = os.path.join(folder, 'views', response.view)
        if not os.path.exists(filename):
            # Troubleshoot suggested by http://groups.google.com/group/web2py/browse_thread/thread/1c9ed82b640d04a9/82c734b68b79a16a?lnk=gst&q=invalid+view#82c734b68b79a16a
            badv = filename
            raise HTTP(404,
                       rewrite.thread.routes.error_message % badv,
                       web2py_error=badv)
        layer = filename
        if is_gae:
            ccode = getcfs(layer, filename,
                           lambda: compile2(parse_template(response.view,
                                            os.path.join(folder, 'views'),
                                            context=environment),layer))
        else:
            ccode = parse_template(response.view,
                                   os.path.join(folder, 'views'),
                                   context=environment)
        restricted(ccode, environment, layer)

def remove_compiled_application(folder):
    """
    Deletes the folder `compiled` containing the compiled application.
    """
    try:
        shutil.rmtree(os.path.join(folder, 'compiled'))
        path = os.path.join(folder, 'controllers')
        for file in listdir(path,'.*\.pyc$',drop=False):
            os.unlink(file)
    except OSError:
        pass


def compile_application(folder):
    """
    Compiles all models, views, controller for the application in `folder`.
    """
    remove_compiled_application(folder)
    os.mkdir(os.path.join(folder, 'compiled'))
    compile_models(folder)
    compile_controllers(folder)
    compile_views(folder)


def test():
    """
    Example::

        >>> import traceback, types
        >>> environment={'x':1}
        >>> open('a.py', 'w').write('print 1/x')
        >>> save_pyc('a.py')
        >>> os.unlink('a.py')
        >>> if type(read_pyc('a.pyc'))==types.CodeType: print 'code'
        code
        >>> exec read_pyc('a.pyc') in environment
        1
    """

    return


if __name__ == '__main__':
    import doctest
    doctest.testmod()



