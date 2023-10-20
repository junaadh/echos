# echos
 write arguments to standerd output

## synopsis
 echos writes any specified operands, seperated by single blank (' ') to stdout
 normally echos clears the buffer with a newline ('\n')

## usage
 echos [-n] [string ...]

 The following options are available
    -n    Do not print newline character

## exit status
 the echos utility exits with 0 status on sucess, and >0 if an error occurs

## development
 built for arm64 aarch on an apple silicon m2
 
 cd into directory
 ```
  cd echos
 ```

 to build run
 ```
  as -arch arm64 -o echos.o echos.s
 ```

 now compile binary with
 ```
  ld -o echos echos.o -lSystem -syslibroot $(xcrun -sdk macosx --show-sdk-path) -e _start 
 ```

 run binary with
 ```
  ./echos
 ```
