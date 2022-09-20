# V2:switch to https://github.com/lh3/biofast/blob/master/lib/klib.cr
require "./klib"
include Klib

def read_fastx_by_klib(fafq : String)
  fp = GzipReader.new(fafq)
  fx = FastxReader.new(fp)
  while (r = fx.read) >= 0
    # n += 1
    # slen += fx.seq.size
    # qlen += fx.qual.size
    # p! "id=#{fx.name.to_s}\tseq=#{fx.seq.to_s}"
    # puts "#{fx.seq.size}\t#{fx.name.to_s}"
    # yield fx.name.to_s, fx.seq.to_s, fx.qual.to_s
    yield fx
  end
  # puts "#{n}\t#{slen}\t#{qlen}"
  raise "ERROR: malformatted FASTX" if r != -1
  fp.close
end

def read_fasta_to_hash(fasta : String | IO::FileDescriptor, chrs : Array = [] of String) # return hash
  # puts "chrs=#{chrs}"
  # puts "#start read fasta #{fasta}"
  chrs_size = chrs.size

  # return hash
  if fasta.is_a?(String)
    #fx_hash = {} of String => Klib::FastxReader(Klib::GzipReader)
    fx_hash = {} of String => String
    read_fastx_by_klib(fasta) do |fx|
      name = fx.name.to_s
      next if chrs_size != 0 && !(chrs.includes?(name))
      raise "error: id #{name} occur more than one times in #{fasta} \n" if fx_hash.has_key?(name)
      fx_hash[name] = fx.seq.to_s # fx.name.to_s, fx.seq.to_s, fx.qual.to_s
    end
  else
    fx_hash = {} of String => String
    fx_hash = read_fasta_from_io(fasta, chrs: chrs)
  end
  return fx_hash
end

def read_fasta(fasta : String | IO::FileDescriptor, chrs : Array = [] of String) # return yeild
  # puts "chrs=#{chrs}"
  # puts "#start read fasta #{fasta}"
  chrs_size = chrs.size

  if fasta.is_a?(String)
    read_fastx_by_klib(fasta) do |fx|
      next if chrs_size != 0 && !(chrs.includes?(fx.name.to_s))
      yield fx
    end
  else
    read_fasta_from_io(fasta, chrs: chrs, to_yield: true) do |fx|
      yield fx
    end
  end
end

def read_fasta_from_io(fio : IO::FileDescriptor, chrs : Array = [] of String, to_yield : Bool = false) # STDIN

  ref = {} of String => String
  id = ""
  seq = Array(String).new(1000)
  chrs_size = chrs.size
  skip_chr = false
  got_chrs_size = 0

  fio.each_line do |line|
    if line.starts_with?(">")
      # raise "error: not support line: #{line} in #{fasta}\n" if line.match(/^>\s/)
      unless id == ""
        if to_yield
          yield [id, seq.join("")]
        else
          raise "error: id #{id} occur more than one times in #{fasta} \n" if ref.has_key?(id)
          ref[id] = seq.join("")
        end
      end
      id = line[1..].split[0]
      seq = Array(String).new(1000)
      # puts "reading #{id}"
      if chrs_size >= 1
        skip_chr = (chrs.includes?(id)) ? false : true
      end
      if skip_chr
        id = ""
        break if got_chrs_size == chrs_size
      else
        got_chrs_size += 1
      end
    elsif skip_chr == false
      seq << line
    end
  end
  unless id == ""
    if to_yield
      yield [id, seq.join("")]
    else
      raise "error: id #{id} occur more than one times in #{fasta} \n" if ref.has_key?(id)
      ref[id] = seq.join("")
    end
  end
  raise "sorry, occur a bug: not get all #{chrs} for #{fasta}. If you give a github issue, I will appreciate it~\n" if chrs_size >= 1 && ref.keys.size != chrs_size
  # puts "#end read fasta #{fasta}"
  return ref if !to_yield
end

def test
  p! ARGV[0]
  read_fasta(ARGV[0]).each do |name, seq|
    puts "#{seq.size}\t#{name}"
  end
end

# test()
