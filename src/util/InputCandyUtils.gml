///@package com.la-game-studio.input-candy.util
///@description Fork of https://github.com/LAGameStudio/InputCandy/commit/0d1b0c82fdbcc5367384916edba5daa3f8dc3fd8

/* 
   The following functions are required for use by InputCandy.  (Not InputCandySimple)
   They are really useful functions, you should use them too.  (c) 2020 LostAstronaut.com
 */

// Loads a file into a string.
function file_as_string( filename ) {
 var buffer="",fp;
 if ( !file_exists(filename) ) return "";
 fp = file_bin_open(filename, 0);
 while( file_bin_position(fp) != file_bin_size(fp) )
  buffer += chr(file_bin_read_byte(fp));
 file_bin_close(fp);
 return buffer;
}

// Saves a file out as a string.
function string_as_file( filename, output ) {
 var fp=file_text_open_write(filename);
 file_text_write_string(fp,output);
 file_text_close(fp);
}

// Loads a JSON file
function load_json( filename, defaultStruct ) {
 if ( !file_exists(filename) ) return defaultStruct;
 var buffer="";
 fp = file_bin_open(filename, 0);
 while( file_bin_position(fp) != file_bin_size(fp) ) buffer += chr(file_bin_read_byte(fp));
 file_bin_close(fp);
 return json_parse(buffer);	
}

// Saves a struct as JSON
function save_json( filename, dataOut ) {
 return string_as_file( filename, json_stringify(dataOut) );
}

// Random sign positive or negative times a magnitude argument0
function random_posneg(argument0) {
	return random(argument0)*randomsign();
}

// Randomly + or -
function randomsign() {
	if ( random(50000) % 2 == 1 ) return -1;
	else return 1;
}

// A random range m-n, works in the positive case.  Ex rrange(1,5), whereas rrange(-2,2) is -2 to 0
function rrange(m, n) {
	return m+random(n-m);
}

// Here for legacy reasons.  See DikuMUDs.
function number_range(m, n) {
	return m+random(n-m);
}

// Returns a fuzzy number in a range r around a value a, example  fuzzy(50,25) returns numbers 25 to 75
function fuzzy(a, r) {
	return (a+(random(r*2)-r));
}

/// @description  color_fuzzy(r1,r2,g1,g2,b1,b2);
function color_fuzzy(r1, r2, g1, g2, b1, b2) {
	return make_color_rgb(
	 number_range(r1,r2),
	 number_range(g1,g2),
	 number_range(b1,b2)
	);
}

// Multiply color by a scale, where 1.0 is the original value and 0.5 is "half the original color"
function color_mult(color,scale) {
	var r=color_get_red(color) * scale;
	var g=color_get_green(color) * scale;
	var b=color_get_blue(color) * scale;
	if ( r > 255 ) r=255;
	if ( g > 255 ) g=255;
	if ( b > 255 ) b=255;
	return make_color_rgb(r,g,b);
}

// Shorthand to turn a Real into a String
function int(a) {
	return string_format(a,1,0); 
}

/*  Usage: arr = string_split(data,sep);
**  Arguments:
**      d        array data, string
**      s         seperator character, string
**  Returns: array
**  Notes: Converts a string of data with elements seperated by a delimiter into an array of strings.
 */
function string_split(d,s) {
    var slen,i,p,out=[];
	d += s;
    slen = string_length(s);
    i = 0;
    repeat (string_count(s,d)) {
        p = string_pos(s,d)-1;
		out[i]=string_copy(d,1,p);
        d = string_delete(d,1,p+slen);
        i += 1;
    }
    return out;
}

// The C/C++ version of A % B with float/decimals.
function fmod(a, b) {
  return (a/b - floor(a/b));
}