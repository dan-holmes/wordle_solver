words = File.readlines('wordle-answers.txt').map {|w| w.strip};

def most_common_letters(words)
    letter_count = Hash.new(0);
    for word in words
        letters = word.split('');
        for letter in letters
            letter_count[letter] += 1
        end
    end
    letter_count.sort_by {|k, v| -v}.map {|k, v| k}.take(5);
end

def most_common_place_for_letter(letter, words)
    place_count = Hash.new(0);
    for word in words
        for i in 0..4
            place_count[i] += 1 if (word[i] == letter)
        end
    end
    place_count.sort_by {|k, v| -v}.map {|k, v| k}.first
end

def possible_words(gathered_info, words)
    for row in gathered_info do
        correct_letters = []
        incorrect_letters = []
        row[:guess].each_char.with_index { |letter, i|
            code = row[:result][i]
            if (code == 2)
                words.select! { |w| w[i] == letter }
                correct_letters.push(letter)
            elsif (code == 1)
                words.select! { |w| w[i] != letter }
                correct_letters.push(letter)
            elsif (code == 0)
                incorrect_letters.push(letter)
            end
        }

        shadow_words = Hash[words.collect { |w| [w, w]}];

        correct_letters.each { |letter|
            shadow_words.select! {|word, shadow_words| word.include?(letter)}
            shadow_words = shadow_words.map do |word, shadow_word|
                if (shadow_word.include?(letter))
                    shadow_word_array = shadow_word.split('')
                    shadow_word_array.delete_at(shadow_word.index(letter))
                    new_shadow_word = shadow_word_array.join()
                else
                    new_shadow_word = ''
                end
                [word, new_shadow_word]
            end.to_h
        }

        incorrect_letters.each { |letter|
            shadow_words.select! { |word, shadow_words|
                !shadow_words.include?(letter)
            }
        }
        words = shadow_words.map {|k, v| k}
    end
    words
end

def guess_score(word, words)
    score = 0
    mcl = most_common_letters(words);
    word.split('').uniq.each_with_index do |letter, i|
        if (mcl.include? (letter))
            score += 1
            if (most_common_place_for_letter(letter, words) == i)
                score += 1
            end
        end
    end
    score
end

def best_guess(gathered_info, words)
    return 'crate' if gathered_info.empty? #cached best starting word
    pw = possible_words(gathered_info, words)
    puts "thinking... (#{pw.count} possible words)"
    guess_scores = Hash.new(0)
    for word in pw do
        guess_scores[word] = guess_score(word, pw)
    end
    guess_scores.sort_by {|k, v| -v}.map {|k, v| k}.first
end

won = false
gathered_info = []
while (!won) do
    guess = best_guess(gathered_info, words)
    puts "Guess the word: #{guess}"
    new_info = {
        guess: guess,
        result: []
    }
    puts "Enter result  with 2 for green, 1 for gold, 0 for grey e.g. 01002"
    new_info[:result] = gets.chomp.split('').map{|c| c.to_i}
    if (new_info[:result].all? {|v| v == 2})
        won = true
        puts "Nice work!"
    end
    gathered_info.push(new_info)
end