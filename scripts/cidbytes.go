package main

import (
	"fmt"
	"github.com/ipfs/go-cid"
	"os"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Usage: ./cidbytes <string>")
		os.Exit(1)
	}
	piece_cid := os.Args[1]
	pieceCid, _ := cid.Parse(piece_cid)
	fmt.Println(pieceCid.Bytes())
}
