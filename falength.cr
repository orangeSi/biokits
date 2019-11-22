require "admiral"
require "gzip"



class FaLen < Admiral::Command
	define_argument fa,
		description: "genome.fa or genome.fa.gz",
		required: true
	define_help description: "A command for ouput sequence length for fasta format file\nAuthor: ilikeorangeapple@gmail.com. 2019"
	define_version "1.0.0"

	def run
		self.help_when_no_output # when no --help will output help info
		fafile = arguments.fa
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
		raise "error: --ref #{file} not exists" if ! File.exists?(file)
		#puts "file_type is #{file_type}"
		id,  seqlen = "", 0
		if file_type == "fasta"
			File.each_line(file) do |line|
				id, seqlen = self.readline(line, id, seqlen)
			end
			id, seqlen = self.readline(">", id, seqlen)
		elsif file_type == "fasta_gz"
			Gzip::Reader.open(file) do |gfile|
				gfile.each_line do |line|
					id, seqlen  = self.readline(line, id, seqlen)
				end
			end
			id, seqlen = self.readline(">", id, seqlen)
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
			seqlen += line.gsub(/\s/, "").size
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


end

FaLen.run 

