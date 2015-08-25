#!/usr/bin/env gnuplot
#

#set terminal png size 1200,800
#set output "isi.png"
set terminal pdf monochrome font "Times,12" size 14cm,10cm
set style fill solid 1.0 border -1
set boxwidth 0.5
set title "Runtime of Tape Library Simulation"
set ylabel "Runtime (seconds)"
set xlabel "Number of total processes\n(multiples of 8 drives, 1 changer, 16 clients)"
set logscale xy
set key bottom right
set key spacing 1.2
set offset graph 0.02, 0.10

#set style line 1 default
#set style line 2 lt 0 pt 0
#set style line 2 lt 1 pt 1

set termoption dashed

#set style line 1 lt 1 pt 6
#set style line 2 lt 2
#set style line 3 lt 3
#set style line 4 lt 3

set title "Runtime of Tape Library Simulation on 1 core"
set output "1-core.pdf"
plot \
	"isi.dat" index 0 using 1:2         title "unbuffered"   with linespoints, \
	"isi.dat" index 1 using 1:2         title "bufsize=100"  with linespoints, \
	"isi.dat" index 2 using 1:2         title "bufsize=1000" with linespoints, \

set title "Runtime of Tape Library Simulation on 2 cores"
set output "2-cores.pdf"
plot \
	"isi.dat" index 0 using 1:3         title "unbuffered"   with linespoints, \
	"isi.dat" index 1 using 1:3         title "bufsize=100"  with linespoints, \
	"isi.dat" index 2 using 1:3         title "bufsize=1000" with linespoints

set title "Runtime of Tape Library Simulation on 4 cores"
set output "3-cores.pdf"
plot \
	"isi.dat" index 0 using 1:4         title "unbuffered"   with linespoints, \
	"isi.dat" index 1 using 1:4         title "bufsize=100"  with linespoints, \
	"isi.dat" index 2 using 1:4         title "bufsize=1000" with linespoints, \

set title "Runtime of Tape Library Simulation on 8 cores"
set output "4-cores.pdf"
plot \
	"isi.dat" index 0 using 1:5         title "unbuffered"   with linespoints, \
	"isi.dat" index 1 using 1:5         title "bufsize=100"  with linespoints, \
	"isi.dat" index 2 using 1:5         title "bufsize=1000" with linespoints

set title "Runtime of Tape Library Simulation with unbuffered channels"
set output "unbuffered.pdf"
plot \
	"isi.dat" index 0 using 1:2         title "1 core"       with linespoints, \
	"isi.dat" index 0 using 1:3         title "2 cores"      with linespoints, \
	"isi.dat" index 0 using 1:4         title "4 cores"      with linespoints, \
	"isi.dat" index 0 using 1:5         title "8 cores"      with linespoints

set title "Runtime of Tape Library Simulation with buffered channels (size 100)"
set output "buffered-100.pdf"
plot \
	"isi.dat" index 1 using 1:2         title "1 core"       with linespoints, \
	"isi.dat" index 1 using 1:3         title "2 cores"      with linespoints, \
	"isi.dat" index 1 using 1:4         title "4 cores"      with linespoints, \
	"isi.dat" index 1 using 1:5         title "8 cores"      with linespoints


#plot \
	"isi.dat" index 0 using 1:2:xtic(1) title "1 core, unbuffered" with linespoints, \
	"isi.dat" index 0 using 1:3 title "2 cores, unbuffered" with linespoints, \
	"isi.dat" index 0 using 1:4 title "4 cores, unbuffered" with linespoints, \
	"isi.dat" index 0 using 1:5 title "8 cores, unbuffered" with linespoints, \
	\
	"isi.dat" index 1 using 1:2 title "1 core,  bufsize=100" with linespoints, \
	"isi.dat" index 1 using 1:3 title "2 cores, bufsize=100" with linespoints, \
	"isi.dat" index 1 using 1:4 title "4 cores, bufsize=100" with linespoints, \
	"isi.dat" index 1 using 1:5 title "8 cores, bufsize=100" with linespoints, \
	\
	"isi.dat" index 2 using 1:2 title "1 core,  bufsize=1000" with linespoints, \
	"isi.dat" index 2 using 1:3 title "2 cores, bufsize=1000" with linespoints, \
	"isi.dat" index 2 using 1:4 title "4 cores, bufsize=1000" with linespoints, \
	"isi.dat" index 2 using 1:5 title "8 cores, bufsize=1000" with linespoints

