use lib 't/04-nativecall';
use CompileTestLib;
use NativeCall;
use Test;

plan 12;

compile_test_lib('02-simple-args');

# Int related
sub TakeInt(int32)                      returns int32 is native('./02-simple-args') { * }
sub TakeTwoShorts(int16, int16)         returns int32 is native('./02-simple-args') { * }
sub AssortedIntArgs(int32, int16, int8) returns int32 is native('./02-simple-args') { * }
is TakeInt(42),                    1, 'passed int 42';
is TakeTwoShorts(10, 20),          2, 'passed two shorts';
is AssortedIntArgs(101, 102, 103), 3, 'passed an int32, int16 and int8';

# Float related
sub TakeADouble(num64) returns int32 is native('./02-simple-args') { * }
sub TakeAFloat(num32)  returns int32 is native('./02-simple-args') { * }
is TakeADouble(-6.9e0), 4, 'passed a double';
is TakeAFloat(4.2e0),   5, 'passed a float';

# String related
sub TakeAString(Str) returns int32 is native('./02-simple-args') { * }
is TakeAString('ok 6 - passed a string'), 6, 'passed a string';

# Explicitly managing strings
sub SetString(Str) returns int32 is native('./02-simple-args') { * }
sub CheckString()  returns int32 is native('./02-simple-args') { * }
my $str = 'ok 7 - checked previously passed string';
explicitly-manage($str);
SetString($str);
is CheckString(), 7, 'checked previously passed string';

# Make sure wrapped subs work
sub wrapped(int32) returns int32 is native('./02-simple-args') { * }
sub wrapper(int32 $arg) { is wrapped($arg), 8, 'wrapped sub' }
wrapper(42);

# 64-bit integer
sub TakeInt64(int64) returns int32 is native('./02-simple-args') { * }
is TakeInt64(0xFFFFFFFFFF), 9, 'passed int64 0xFFFFFFFFFF';

# Unsigned integers.
sub TakeUint8(uint8) returns int32 is native('./02-simple-args') { * }
sub TakeUint16(uint16) returns int32 is native('./02-simple-args') { * }
sub TakeUint32(uint32) returns int32 is native('./02-simple-args') { * }
is TakeUint8(0xFE),        10, 'passed uint8 0xFE';
is TakeUint16(0xFFFE),     11, 'passed uint8 0xFFFE';
is TakeUint32(0xFFFFFFFE), 12, 'passed uint8 0xFFFFFFFE';

# vim:ft=perl6
