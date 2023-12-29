all: compile run clean

compile:
	nasm -felf64 src/main.asm -o main.o
	nasm -felf64 src/list.asm -o list.o
	gcc main.o list.o -o list

run:
	./list

clean:
	rm -fr list.o main.o list