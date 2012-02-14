# -*- coding: utf-8 -*-
from random import Random

def game():
    return dict(message="test")

def serve_dict():
    # Serves the generic dictionary 
    return dict(message="Jack the dict in here")

# Stored as string, parsed into XML
def serve_player_data():
    
    player_ID = request.vars.player_ID
    opponent_ID = request.vars.opponent_ID
    game_ID = request.vars.game_ID
    
    game_data = get_player_data(player_ID,opponent_ID,game_ID);
    return dict(game_data=game_data)

def get_player_data(player_ID,opponent_ID,game_ID):
    
    # Generate the player data
    if(int(game_ID)==0):
        letter_data = generate_new_letter_data()
        event_data = generate_new_event_data()
#        db.game_data_table.insert(player_1_ID = int(player_ID),
#                                  player_2_ID = int(opponent_ID),
#                                  event_string = str(event_data),
#                                  letter_string = str(letter_data)
#                                  )
        game_data = letter_data + "&" + event_data
    else:
        game_row = db(db.game_data_table.id==int(game_ID)).select().first()
        game_data = str(game_row.game_events_string)
        
    return game_data

def generate_new_letter_data():

    NUM_LETTERS = 12
    letter_string = get_random_letters(NUM_LETTERS)
    return letter_string

def generate_new_event_data():
    NUM_EVENTS = 24 # 2 MINUTES. 1 EVENT EVERY 5 SECS
    random_letter_events_string = get_random_letter_events_string(NUM_EVENTS/2)
    random_mult_events_string = get_random_mult_events_string(NUM_EVENTS/2)
    return random_letter_events_string + random_mult_events_string

def get_random_letter_events_string(len_req):
    letter_event = "0"
    num_events = 0
    random_letter_events = ""
    while num_events < len_req:
        random_letter_events += letter_event # Generate a new type
        random_letter_events += ","
        random_letter_events += get_random_letters(1) # Generate a new letter
        random_letter_events += ","
        random_letter_events += get_random_location() # Generate a new location
        random_letter_events += "*"
        num_events += 1
    
    return random_letter_events

def get_random_mult_events_string(len_req):
    random_mult_events_string = ""
    mult_event = "1"
    num_events = 0

    while num_events < len_req:
        random_mult_events_string += mult_event # Generate a new type
        random_mult_events_string += ","
        random_mult_events_string += get_new_mult_type() # Generate new mult tpye
        random_mult_events_string += ","
        random_mult_events_string += get_random_location() # Generate a new location
        random_mult_events_string += "*"
        num_events+=1
    return random_mult_events_string


def get_random_letters(len_req):
    import random
    # ord - letter to ASCII
    # chr - ASCII to letter
    #A - 65
    # Z- 90
    
    A = 65
    Z = 90
    rand_letter_string =""
    while len(rand_letter_string) < len_req:
        rand_int = random.randint(A,Z)
        rand_letter_string+= chr(rand_int)
        
    return rand_letter_string

def get_random_location():
    import random
    # 0-based 12-tile index
    # 0 <= X <= 11
    return str(random.randint(0,11))


def get_new_mult_type():
    import random
    # 0 - 2x - 60%
    # 1 - 3x - 30%
    # 2 - 4x - 10%
    rand_int = random.randint(0,10)
    
    if rand_int < 6:
        return "0"
    elif rand_int <9:
        return "1"
    else:
        return "2"