module Proso

  class Dictionary
    
    require 'treat'
    require 'json'
    include Treat::Core::DSL

    SEMI_SCUDS = %w{a all am an and are as at be been but by can could dear did do does else for from get got had has have he her hers him his how i if in is it its just least let like may me might most must my no nor not of off on or our own said say says she should since so some than that the their them then there these they this tis to too twas us wants was we went were what when where which while who whom why will with would yet you your}

    def initialize
      @dict = load_from_json(File.expand_path('../../data/cmudict.json', __FILE__))
    end

    def load_from_json(filepath)
      File.open("#{filepath}", "r") do |f|
        JSON.parse(File.read(f))
      end
    end

    def self.serialize_cmudict(filepath)
      cmudict = File.open(filepath, 'r'){ |f| f.read }
      matches = cmudict.scan(/^([\w\d'-]+)(\(\d+\))?\s+([\w\d ]+)$/)
      dict = matches.inject({}) do |memo, e|
        memo[e[0]] = memo[e[0]] ? memo[e[0]] << e[2] : [e[2]]
        memo
      end
      File.open("#{filepath}", "w") do |f|
        f.write(dict.to_json)
      end
    end

    def inspect
      "#<Proso::Dictionary:#{object_id}>"
    end

    def stress_distance(string, meter)
      begin
        stresses(string)
          .map{ |s| levenshtein_distance(s, meter*(s.size / 2)) }.min
      rescue RuntimeError => e
        puts e
        return Float::INFINITY 
      end
    end
    
    def token_stress(string)
      return ["0"] if SEMI_SCUDS.include? string.downcase
      @dict[string.upcase] or raise "No pronunciation entry for '#{string}'"
    end
    
    def stresses(string)
      p = phrase(string)
        .do(:tokenize)
        .map(&:value)
        .reject{ |t| /[[:punct:]]/.match(t) }
        .map{ |t| token_stress(t) }
      first, *rest = *p
      combinations = first
        .product(*rest)
        .map(&:join)
        .map{ |t| t.gsub(/\D/, '') }
        .map{ |t| t.gsub(/[123]/, 's') }
        .map{ |t| t.gsub(/0/, 'w') }
        .map{ |t| attridgify(t) }
        .uniq
    end

    def attridgify(string)
      # Basically we coerce the stress pattern into the best plausible
      # Attridge beat/offbeat representation. This considers any number of
      # Attridge-permissible changes equally, so it won't differentiate between
      # the simplicity of the string's fulfillment of a metrical contract.
      string
        .gsub(/www/, 'oBo')
        .gsub(/sss/, 'BoB')
        .gsub(/^ss/, 'oB')
        .gsub(/s/, 'B')
        .gsub(/w/, 'o')
        .gsub(/BBB/, 'BoB')
        .gsub(/ooo/, 'oBo')
    end
    
    def levenshtein_distance(s1, s2)
      m = s1.length
      n = s2.length
      return m if n == 0
      return n if m == 0
      d = Array.new(m+1) {Array.new(n+1)}
      (0..m).each{ |i| d[i][0] = i }
      (0..n).each{ |j| d[0][j] = j } 
      (1..n).each do |j|
        (1..m).each do |i|
          d[i][j] = if s1[i-1] == s2[j-1]
                      d[i-1][j-1]
                    else
                      [ d[i-1][j] +1,
                        d[i][j-1]+1,
                        d[i-1][j-1]+1
                      ].min
                    end
        end
      end
      d[m][n]
    end
    
  end
end
