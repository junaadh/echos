.global _start                         // tells linker starting point
.align  2                              // data alignment to make darwin happy

// start of program
_start:
        cmp    x0,  #1                 // checks if correct num of argc
        b.eq   usage                   // if not print usage info
        cmp    x0,  #4
        b.ge   usage

        cmp    x0,  #2                 // check if correct nflag on
        b.eq   no_new_line
        b.ne   new_line

// sets up registers to read argc w nflag
new_line:
        ldr    x11, [x1, #8]           // nflag stored here
        ldr    x12, [x1, #16]          // string to be echosed
        ldr    x14, [x1, #16]          // copy of string 
        
        mov    x10,  #2                // nflag is -n so two counter

// validate nflag
cloop:  
        ldrb   w9,  [x11], #1          // load first byte of nflag
        cmp    w9,  #'n'               // validate if equals to 'n' == #0x6e
        cset   x8,  eq                 // set x8 = 1 if eq
        b.eq   cend                    // goto cend if eq
        
        sub    x10, x10,  #1           // decrement counter
        cmp    x10,  #0                // validate condition
        b.ne   cloop                   // goto start of loop

// setup for getting length of argv[3] w nflag
cend:
        cmp    x8,  #0                 // check if nflag present
        b.eq   endprog                 // if not endprog
        
        mov    x4,  #0                 // setup counter to get length
        b.ne   get_length              // goto getlength of string

// setup for getting length of argv[2] w/o nflag
no_new_line:
        cmp    x8,  #1                 // double check if nflag present
        b.eq   get_length              // skip section if true
        ldr    x12, [x1, #8]           // load string to print
        ldr    x14, [x1, #8]           // copy of string
        mov    x4,  #0                 // setup counter to count length of string
        
// loop while inc counter untill hit \0
get_length:
        ldrb   w6,  [x12], #1          // load next byte of arg
        cbz    w6,  print              // check if byte is null
        add    x4,  x4,    #1          // increment counter
        b      get_length              // loop back

// print string to stdout
print:
        mov    x0,  #0                 // set stdout
        mov    x1,  x14                // load string to print
        mov    x2,  x4                 // load length
        mov    x16, #4                 // call sys write
        svc    #0x80                   // call kernel to execute

        mov    x0,  #0                 // set success return code
        cmp    x8,  #1                 // check if nflag on
        b.eq   end                     // if true skip clear buffer section

// load a \n to clear the buffer
clear:                            
        mov    x0,  #0                 // set stdout          
        adr    x1,  clear_buffer       // load '\n'
        mov    x2,  clear_len          // load length of '\n'
        mov    x16, #4                 // sys call to write
        svc    #0x80                   // call terminate to execute
        
        mov    x0,  #0                 // set success return code
        b      end                     // jump to end of program

// print usage info
usage:
        mov    x0,  #0                 // set stdout
        adrp   x1,  mesg@page          // load mesg address
        add    x1,  x1,  mesg@pageoff  // add mesg address offset
        mov    x2,  mesg_len           // load mesg length
        mov    x16, #4                 // call sys write
        svc    #0x80                   // call kernel to execute

endprog:                          
        mov    x0,  #1                 // set error return code
        b      end                     // jump to end of program

end:
        mov    x16, #1                 // call program terminate
        svc    #0x80                   // kernel terminate program

// buffer clear string
clear_buffer:
        .ascii "\n"

// calculate length of buffer clear
clear_len = . - clear_buffer

// help
mesg:
        .asciz  "NAME\n"
        .asciz  "    echos - write arguments to standerd output\n\n"
        .asciz  "SYNOPSIS\n"
        .asciz  "    echos writes any specified operands, seperated by single blank (' ') to stdout\n"
        .asciz  "    normally echos clears the buffer with a newline ('\\n')\n\n"
        .asciz  "USAGE\n"
        .asciz  "    echos [-n] [string ...]\n\n"
        .asciz  "    The following options are available\n"
        .asciz  "    -n    Do not print newline character\n\n"
        .asciz  "EXIT STATUS\n"
        .asciz  "    the echos utility exits with 0 status on sucess, and >0 if an error occurs\n\n"

// help msg length
mesg_len = . - mesg
