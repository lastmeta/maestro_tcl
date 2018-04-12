import manage_db

db = manage_db.Database_Connection('testing')


def encode(state):
    '''
    This method takes a state such as ABC and for each character asks the
    database if it has seen in that index before. If so, we save that node,
    if not add it into the database and saves the node in cursor.lastrowid.
    Return the node list as a sparse encoding of that state representation.
    '''
    sdr = []
    for ix,char in enumerate(state):
        rows = db.select_sdr_node(char, ix)
        if rows == []:
            last_row = db.insert_sdr(char, ix)
            sdr.append(last_row)
        else:
            sdr.append(rows[0][0])
    return sdr

def decode(sdr):
    '''
    This method takes an sdr such as [16,43,964,274,348,678] and compiles a
    list of each index that is 1. It gets all those nodes from the database
    and compiles a string out of them corresponding to and returns the
    approapriate state representation.
    '''
    state_list = []
    for index in sdr:
        rows = db.select_sdr_input_ix(index)
        state_list.append(rows[0])
    sorted_state = sorted(state_list, key=lambda tup: tup[1])
    state = ''.join([x[0] for x in sorted_state])
    return state

print(encode('ABC'))
print(encode('BDC'))
print(decode([3,2,4]))
