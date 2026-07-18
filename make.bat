REM This is a batch script for compiling OpenFerainOS, and the final results are presented in the Image folder.
mkdir Image
REM This is the step of reading compilation options.
set "OPT1=" 
for /f "skip=2 delims=" %%a in (Option\Compilation_options.Inf) do (
    set "OPT1=%%a"
    goto :got_opt1
)
:got_opt1
set "GCC=" 
for /f "skip=4 delims=" %%a in (Option\Compilation_options.Inf) do (
    set "GCC=%%a"
    goto :got_opt2
)
:got_opt2
REM This is the source file compilation stage.
nasm %OPT1% Sources\Boot\setup.asm -o Image\setup.bin
nasm %OPT1% Sources\Boot\16T32.asm -o Image\16T32.bin
nasm %OPT1% Sources\Kernel\KERNEL.asm -o Image\KERNEL.bin
%GCC% Sources\Application\cmd.c -o Image\cmd.elf
objcopy -O binary Image\cmd.elf Image\cmd.bin
REM This is the mirror stitching step.
copy /b Image\setup.bin + Image\16T32.bin + Image\KERNEL.bin + Image\cmd.bin Image\OpenFerainOS26.0.img
REM This is the deletion step.
del Image\cmd.elf
del Image\setup.bin
del Image\16T32.bin
del Image\KERNEL.bin
del Image\cmd.bin

pause
exit