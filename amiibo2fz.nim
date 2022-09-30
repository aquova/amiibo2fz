import os, strformat, strutils

const DATA_LEN = 540
const NUM_PAGES = 135
const UID_IDX = [0, 1, 2, 4, 5, 6, 7]

proc main() =
    if paramCount() < 1:
        echo("amiibo2fz path/to/amiibo.bin")
        quit(0)

    var
        bin, fz: File
        buf: array[DATA_LEN, uint8]

    let bin_filename = paramStr(1)
    let bin_success = bin.open(bin_filename, FileMode.fmRead)
    if not bin_success:
        echo("Unable to open ", bin_filename)
        quit(1)

    let fz_filename = bin_filename.changeFileExt("nfc")
    let fz_success = fz.open(fz_filename, FileMode.fmWrite)
    if not fz_success:
        echo("Unable to open ", fz_filename)
        quit(1)

    discard bin.readBytes(buf, 0, DATA_LEN)

    fz.writeLine("Filetype: Flipper NFC device")
    fz.writeLine("Version: 2")
    fz.writeLine("Device type: NTAG215")

    var uid = "UID:"
    for idx in UID_IDX:
        uid &= fmt" {buf[idx]:02X}"
    fz.writeLine(uid)
    fz.writeLine("ATQA: 44 00")
    fz.writeLine("SAK: 00")
    fz.writeLine("Data format version: 1")

    let sig = " 00".repeat(32)
    fz.writeLine("Signature:" & sig)
    fz.writeLine("Mifare version: 00 04 04 02 01 00 11 03")
    for i in 0..2:
        fz.writeLine(fmt"Counter {i}: 0")
        fz.writeLine(fmt"Tearing {i}: 00")

    fz.writeLine("Pages total: 135")
    fz.writeLine("Pages read: 135")

    for i in 0..<NUM_PAGES:
        var page_line = fmt"Page {i}:"
        for j in 0..3:
            let idx = 4 * i + j
            page_line &= fmt" {buf[idx]:02X}"
        fz.writeLine(page_line)

    bin.close()
    fz.close()

when isMainModule:
    main()
