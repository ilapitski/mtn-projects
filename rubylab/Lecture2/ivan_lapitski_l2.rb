#!/usr/bin/env ruby

#Fibonacci sequence
# def fibonacci(n)
#   i1 = 0
#   i2 = 1
#   n.times do
#     i1, i2 = i2, i1+i2
#   end
#   i1
# end
#
# print 'Fibonacci sequence: '
# ARGV[0].to_i.times do |n|
#   print fibonacci(n), ' '
# end
# puts "\n"

# puts 'Change string in place:'
# puts "str0 value was #{ str0 = 'dniMyMdegnahCybuR' }"
# puts "str0 value become #{ str0.reverse!.downcase!.capitalize! }", "\n"
#
# puts 'Integer reverse:'
# puts "int0 value was #{ int0 = 1234567 }"
# puts "int0 value become #{ int0.to_s.reverse!.to_i } and its class is #{ int0.class }", "\n"
#
# int1 = 1234
# sum = int1.to_s.scan(/\d/).map {|i| i.to_i}.inject(:+)
# puts "Sum of numerals in #{ int1 } =  #{ sum }", "\n"
#
# str1 = 'AAa magic Aoh ajA'
# puts "Number of 'a' in '#{ str1 }' is #{ str1.downcase.count('a') }", "\n"
#
# str2 = 'asdf fdsa'
# class String
#   def palindrome?
#     pal0 = self.downcase.scan(/\w/)
#     pal0 == pal0.reverse
#   end
# end
# puts "'#{ str2 }' is palindrome?:  #{str2.palindrome?}", "\n"
#
# puts 'Range from 10 to 3 without 5:'
# r = 10..3
# (r.first).downto(r.last).each do |i|
#   if i == 5
#     next
#   elsif i % 3 == 0
#     print "#{i*i} "
#   else
#     print "#{i} "
#   end
# end
# puts "\n\n"
#
# shop = { milk: 10, bread: 8, cornflakes: 12, ice_cream: 15, pie: 20 }
# val0 = 15
# puts "Does shop has value #{val0}? #{shop.has_value?(15)}"
# print 'Key of this value is value is '; puts shop.select{|key, value| value == val0 }.keys

ar = [1, 6, 1, 8, 2, -1, 3, 5]
puts "ar before #{ar}"
index0 = ar.each_index.max_by { |i| ar[i] }
value0 =  ar.values_at(index0).to_s.to_i
ar[index0] = value0 + 100
puts "ar after #{ar}"

