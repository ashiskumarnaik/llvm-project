! Simple Fortran program to demonstrate LLVM IR generation
program example
    integer :: result
    result = add_numbers(5, 3)
    print *, 'Result:', result
contains
    function add_numbers(a, b) result(sum)
        integer, intent(in) :: a, b
        integer :: sum
        sum = a + b
    end function add_numbers
end program example
