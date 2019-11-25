require "admiral"
require "gzip"



class FaLen < Admiral::Command
	define_argument fa,
		description: "genome.fa or genome.fa.gz",
		required: false
	define_help description: "A command for ouput sequence length for fasta format file\nAuthor: ilikeorangeapple@gmail.com. 2019"
	define_version "1.0.0"

	def run
		self.help_when_no_output # when no --help will output help info
		if ARGV.size == 1 && ARGV[0] == "-"
			self.readfasta("", file_type: "stdin")
			exit(0)
		end
		fafile = arguments.fa || ""
		if fafile.match(/\.fa$/) || fafile.match(/\.fasta$/) || fafile.match(/\.fna$/)
			self.readfasta(fafile, file_type: "fasta") 
		elsif fafile.match(/\.gz$/)
			self.readfasta(fafile, file_type: "fasta_gz")
		else
			puts "error: not support #{fafile}, only fa/fasta/fna/gz\n"
			exit(1)
		end
	end

	def readfasta(file : String, file_type = "fasta")
		id,  seqlen = "", 0
		self.yieldfasta(file, file_type) do |line|
			id, seqlen = self.readline(line, id, seqlen)
		end
		id, seqlen = self.readline(">", id, seqlen)
	end
	def yieldfasta(file : String, file_type = "fasta", &block)
		self.exit "error: --ref #{file} not exists" if file != ""  && ! File.exists?(file)
		#puts "file_type is #{file_type}"
		if file_type == "fasta"
			File.each_line(file) do |line|
				yield line
			end
		elsif file_type == "stdin"
			STDIN.each_line do |line|
				yield line
			end
		elsif file_type == "fasta_gz"
			Gzip::Reader.open(file) do |gfile|
				gfile.each_line do |line|
					yield line
				end
			end
		else
			raise "error: not support file_type=#{file_type}, only len or fasta"
		end
	end
	def readline(line : String, id : String, seqlen : Int32)
		if line.starts_with?('>')
			if id != "" || seqlen != 0
				id_short = id.sub(/^>/, "").sub(/\s.*$/, "")
				raise "error: got one empyt sequence id\n" if id_short.starts_with?(/^\s*$/)
				puts "#{seqlen}\t"+id_short
			end
			id = line
			seqlen = 0
		else
			seqlen += line.strip.size
		end
		return id, seqlen
	end
	def help_when_no_output
		if ARGV.size == 0
			#app = __FILE__.gsub(/\.cr$/, "")
			#puts `#{app} --help`
			#exit 1
			FaLen.run "--help"
		end
	end
	def exit(content : String, status : Int32 = 1)
		puts content
		exit(status)
	end


end

FaLen.run 

