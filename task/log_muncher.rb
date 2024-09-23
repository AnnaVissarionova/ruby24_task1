require 'rubygems/text'
include Gem::Text
# levenshtein_distance('asd', 'sdf') # => 2



class Node


    attr_reader :word, :children

    def initialize(word = "")
      @word = word
      @children = []
    end

    def add_child(word, distance)
      @children.push([distance, Node.new(word)])
    end

    def empty?()
      @word.eql?("")
    end

    class << self
      def add(parent, child)
        distance = levenshtein_distance(parent.word, child.word);
        if distance != 0
          existing_child = parent.children.find {|e| e[0] == distance}

          if existing_child.nil?
            parent.add_child child.word, distance
          else
              Node.add(existing_child[1],child);
          end
        end


      end
    end

end

def get_similar(root, word)
    res = []
    if (root.word == "")
      return res
    end

    distance = levenshtein_distance(root.word, word)
    if distance <= MAX_DIST
      res.push(root.word)
      return res
    end

    unless root.children.empty?
      start = distance - MAX_DIST
      start = 1 if start < 0

      while start <= (distance + MAX_DIST)
          child = root.children.find {|e| e[0] == start}
          tmp = get_similar(child[1], word) unless child.nil?
          if !tmp.nil? && !tmp.empty?
            res.push(tmp[0])
            return res
          end
          start +=1
      end
    end
    res
  end

  def get_similar2(root, word)

    if (root.word == "")
      return nil
    end

    nodes = []
    best_w = nil
    best_d = MAX_DIST
    #best_d = levenshtein_distance(root.word, word)
    nodes.push(root)


    while !nodes.empty?
      cur_node = nodes.pop
      distance = levenshtein_distance(cur_node.word, word)
      if distance < best_d
        best_w = cur_node.word
        best_d = distance

        cur_node.children.each do |child|
          if (child[0] - distance).abs < best_d
            nodes.push(child[1])
          end
        end
      end
    end
    best_w
  end

  def add(parent, child)
    cur_node = parent
    while !cur_node.nil?

      distance = levenshtein_distance(cur_node.word, child.word)
      if distance <= MAX_DIST
        return cur_node.word
      end
      if distance != 0
        existing_child = cur_node.children.find {|e| e[0] == distance}
        if existing_child.nil?
          cur_node.add_child child.word, distance
          cur_node= nil
        else
            cur_node = existing_child[1]
        end
      else
        cur_node= nil
      end
    end
    return nil
  end



    def print_tree(root)
      return if root.nil?

      # Вспомогательная рекурсивная функция для печати
      def print_node(node, level, dist = 0)
        return if node.nil?

        # Выводим текущий узел с отступом, зависящим от уровня
        puts "  " * level + "- #{dist} #{node.word}"

        # Рекурсивно печатаем всех потомков текущего узла
        node.children.each do |child|
          print_node(child[1], level + 1, child[0])
        end
      end

      # Начинаем печать с корня дерева на первом уровне
      print_node(root, 0)
    end


root = Node.new()
MAX_DIST = 4

results = {}
file = File.open('data/log.txt')
file.each_line do |line|
  name = line[line.index('>') + 1 ..line.length].strip.downcase
  if root.empty?
    root = Node.new(name)
    results[name]  = 1
  else
    # res = get_similar(root, name)
    # if res.empty?
    #   w = add(root, Node.new(name))
    #   unless w.nil?
    #     results[w] += 1
    #   else
    #     results[name] = 1
    #   end

    # else
    #   results[res[0]] += 1
    # end

    res = get_similar2(root, name)
    if res.nil?
      w = add(root, Node.new(name))
      unless w.nil?
        results[w] += 1
      else
        results[name] = 1
      end
    else
      results[res] += 1
    end
  end
end


results.each_key do |key|
  puts "#{key}: #{results[key]}"
end

 print_tree(root)
# File.open("out.txt", "w") do |f|
#   results.each_key do |key|
#     f.write("#{key}: #{results[key]}\n")
#   end
# end
