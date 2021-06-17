// This file is part of seq192
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#include "userfile.h"
#include <iostream>

userfile::userfile( string a_name ) :
    configfile( a_name )
{
}

userfile::~userfile( )
{

}



bool
userfile::parse( perform *a_perf )
{

    /* open binary file */
    ifstream file ( m_name.c_str(), ios::in | ios::ate );

    if( ! file.is_open() )
        return false;

    /* run to start */
    file.seekg( 0, ios::beg );

    line_after( &file, "[user-midi-bus-definitions]" );
    int buses = 0;
    sscanf( m_line, "%d", &buses );
    char bus_num[4];

    for ( int i=0; i<buses; i++ )
    {
        snprintf(bus_num, sizeof(bus_num), "%d", i);
        line_after( &file, "[user-midi-bus-" + string(bus_num) + "]");
        global_user_midi_bus_definitions[i].alias = m_line;
        next_data_line( &file );
        int instruments=0;
        int instrument;
        int keymap;
        int channel;

        sscanf( m_line, "%d", &instruments );
        for ( int j=0; j<instruments; j++ )
        {
            keymap = -1;
            next_data_line( &file );
            sscanf( m_line, "%d %d %d", &channel, &instrument, &keymap );
            global_user_midi_bus_definitions[i].instrument[channel] = instrument;
            global_user_midi_bus_definitions[i].keymap[channel] = keymap;
            // printf( "%d %d %d\n", channel, instrument, keymap );
        }
    }

    line_after( &file, "[user-instrument-definitions]" );
    int instruments = 0;
    sscanf( m_line, "%d", &instruments );
    char instrument_num[4];

    for ( int i=0; i<instruments; i++ )
    {
        snprintf(instrument_num, sizeof(instrument_num), "%d", i);
        line_after( &file, "[user-instrument-" + string(instrument_num) + "]");
        global_user_instrument_definitions[i].instrument = m_line;
        // printf( "%d %s\n", i, m_line );
        next_data_line( &file );
        int ccs=0;
        int cc=0;

        char cc_name[1024];

        sscanf( m_line, "%d", &ccs );
        for ( int j=0; j<ccs; j++ )
        {
            next_data_line( &file );
            sscanf( m_line, "%d", &cc );
            sscanf( m_line, "%[^\n]", cc_name );
            global_user_instrument_definitions[i].controllers[cc] = string(cc_name);
            global_user_instrument_definitions[i].controllers_active[cc] = true;
            // printf( "[%d] %s\n", cc, cc_name );
        }
    }

    line_after( &file, "[user-keymap-definitions]" );
    int keymaps = 0;
    sscanf( m_line, "%d", &keymaps );
    char keymap_num[4];

    for ( int i=0; i<keymaps; i++ )
    {
        snprintf(keymap_num, sizeof(keymap_num), "%d", i);
        line_after( &file, "[user-keymap-" + string(keymap_num) + "]");
        global_user_keymap_definitions[i].keymap = m_line;
        // printf( "%d %s\n", i, m_line );
        next_data_line( &file );
        int keys=0;
        int key=0;

        char key_name[1024];

        sscanf( m_line, "%d", &keys );
        for ( int j=0; j<keys; j++ )
        {
            next_data_line( &file );
            sscanf( m_line, "%d", &key );
            sscanf( m_line, "%[^\n]", key_name );
            global_user_keymap_definitions[i].keys[key] = string(key_name);
            global_user_keymap_definitions[i].keys_active[key] = true;
            // printf( "[%d] %s\n", key, key_name );
        }
    }

    file.close();

    return true;
}


bool
userfile::write( perform *a_perf  )
{
    return false;
}
