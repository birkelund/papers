package main

import (
	"flag"
	"fmt"
	"log"
	"math/rand"
	"time"
)

var numDrives = flag.Int("drives", 8, "number of drives")
var numChangers = flag.Int("changers", 1, "number of changers")
var numClients = flag.Int("clients", 16, "number of clients")
var chanBufSize = flag.Int("bufsize", 0, "channel buffer size")

const timeformat = "Jan 2 15:04:05"

func randomDurationNorm(stddev, mean time.Duration) time.Duration {
	return time.Duration(rand.NormFloat64()*float64(stddev) + float64(mean))
}

type library struct {
	changers chan request
	drives   chan request
}

type command int

const (
	mount command = iota
	unmount
	read
	write
)

type response struct {
	t     time.Duration
	ch    chan request
	clock time.Time
}

type request struct {
	cmd   command
	ch    chan response
	clock time.Time
}

func changer(id string, lib *library) {
	var clock time.Time
	var resp response

	ch := make(chan response, *chanBufSize)

	for {
		// a changer gets mount request from a client
		req := <-lib.changers
		if req.clock.After(clock) {
			clock = req.clock
		}
		//fmt.Printf("[%v changer %v] mount request received\n", clock.Format(timeformat), id)

		// wait for a drive to become available
		lib.drives <- request{unmount, ch, clock}
		resp = <-ch

		// update our clock
		clock = resp.clock

		// mount new tape
		lib.drives <- request{mount, ch, clock}
		resp = <-ch

		// update our clock
		clock = resp.clock

		// notify the client that the tape has been mounted
		req.ch <- response{clock.Sub(req.clock), resp.ch, clock}
	}
}

func drive(id string, lib *library) {
	var clock time.Time
	var req request
	var t time.Duration

	ch := make(chan request, *chanBufSize)

	for {
		// a drive first gets a request to mount a tape
		req = <-lib.drives
		if req.clock.After(clock) {
			clock = req.clock
		}

		switch req.cmd {
		case mount:
			// mounts it
			t = randomDurationNorm(time.Second, 15*time.Second)
			clock = clock.Add(t)

			//fmt.Printf("[%v drive %v] mounted in %v\n", clock.Format(timeformat), id, t)
			// send the request channel back
			req.ch <- response{t, ch, clock}

			// get ready to receive a read/write request
			req = <-ch

			// carry out the request
			t = randomDurationNorm(time.Second, 30*time.Second)
			clock = clock.Add(t)

			// and we're done
			req.ch <- response{t, nil, clock}

		case unmount:
			// unmounting
			t = randomDurationNorm(time.Second, 10*time.Second)
			clock = clock.Add(t)

			//fmt.Printf("[%v drive %v] unmounted in %v\n", clock.Format(timeformat), id, t)

			// reply that we're unmounted
			req.ch <- response{t, nil, clock}
		}

		//fmt.Printf("[%v drive %v] done\n", clock.Format(timeformat), id)
	}
}

func client(id string, lib *library) {
	var clock time.Time
	var t time.Duration
	var waitTime, ioTime time.Duration
	var nRequests int
	var today int

	var resp response

	ch := make(chan response, *chanBufSize)

	today = clock.YearDay()

	for clock.YearDay() != 90 {
		if clock.YearDay() != today && id == "1" {
			log.Println(today)
		}
		today = clock.YearDay()

		nRequests++
		t = 0

		// a client requests a tape to be mounted
		//fmt.Printf("[%v client %v] mount request\n", clock.Format(timeformat), id)
		lib.changers <- request{mount, ch, clock}

		// an awaits a reference to the drive that is ready
		resp = <-ch
		clock = clock.Add(resp.t)
		//fmt.Printf("[%v client %v] tape mounted in %v\n", clock.Format(timeformat), id, resp.t)

		waitTime += resp.t

		t += resp.t

		// then sends the request
		resp.ch <- request{read, ch, clock}

		// and awaits completion
		resp = <-ch
		clock = clock.Add(resp.t)
		t += resp.t
		ioTime += resp.t
		//fmt.Printf("[%v client %v] io request finished in %v (total %v)\n",
		//	clock.Format(timeformat), id, resp.t, t)

	}

	//fmt.Printf("[%v client %v] requests: %v waittime: %v (avg: %v) ioTime: %v\n",
	//	clock.Format(timeformat), id, nRequests, waitTime, time.Duration(int(waitTime)/nRequests), ioTime)

}

func NewLibrary(numDrives, numChangers int) *library {
	lib := &library{
		changers: make(chan request, *chanBufSize),
		drives:   make(chan request, *chanBufSize),
	}

	for i := 0; i < numDrives; i++ {
		go drive(fmt.Sprintf("%v", i), lib)
	}

	log.Printf("started %d drives\n", numDrives)

	for i := 0; i < numChangers; i++ {
		go changer(fmt.Sprintf("%v", i), lib)
	}

	log.Printf("started %d changers\n", numChangers)

	return lib
}

func main() {
	flag.Parse()

	log.Println(*chanBufSize)
	lib := NewLibrary(*numDrives, *numChangers)

	for i := 0; i < *numClients; i++ {
		go client(fmt.Sprintf("%v", i), lib)
	}

	log.Printf("started %d clients\n", *numClients)

	select {}
}
