const eol = uint8('\n')
const space = uint8(' ')
const BUFFER_SIZE = 1024*1024
const MAX_DOC_SIZE = 55000

println("Reading file $(ARGS[1])")

input_file = ARGS[1]


dictionary = Dict{String,Uint32}()
lines = 0
function compute_dictionary(fname)
    dictionary = Dict{String,Uint32}()
    fsize = filesize(fname)

    fid = open(fname,"r")

    documents = 0
    buf = zeros(Uint8, BUFFER_SIZE)
    words = Array(UTF8String,MAX_DOC_SIZE)
    dwords = 0
    at_tail = false
    while position(fid) < (fsize - BUFFER_SIZE) || at_tail
        read!(fid, buf)
        prev_pos = 1
        for i in 1:length(buf)
            if buf[i] == space || buf[i] == eol
                # we got word from document
                dwords+=1
                if dwords > MAX_DOC_SIZE
                    println("Exceed MAX_DOC_SIZE ", MAX_DOC_SIZE)
                else
                    words[dwords] = UTF8String(buf[prev_pos:i-1])
                end
                if buf[i] == eol
                    for word in unique(words[1:dwords])
                        dictionary[word] = get(dictionary, word, 0) + 1
                    end
                    dwords = 0
                    documents += 1
                    if documents % 1000 == 0
                      println(documents)
                    end
                end
                prev_pos = i + 1
            end
        end
        if at_tail
            break
        end
        if buf[end] != space || buf[end] != eol
            # reached end of buffer without delimiter
            # rewind to the previous space position
            skip(fid, prev_pos - BUFFER_SIZE - 1)
        end
        if position(fid) >= (fsize-BUFFER_SIZE)
            buf = zeros(Uint8, fsize - position(fid))
            at_tail = true
        end
    end
    dictionary, documents
end

@time begin
dic, lines = compute_dictionary(input_file)
end

println("Dile $input_file has $lines lines")
println("Done:\t$(length(dic)) unique words collected.")

@time begin
    dic_file = open("dictionary.txt","w")
    for (k, v) in dic
      print(dic_file,"$k $v\n")
    end
    #serialize(dic_file,dic)
    flush(dic_file)
    close(dic_file)
end
