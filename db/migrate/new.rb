
(1..100).each do |n|

  if (n % 3 == 0)
    puts "foo"

  elsif (n % 5 == 0)

    puts "bar"

  elsif (n % 3 && n % 5 == 0)

    puts "foobar"

  else

    puts n



  end

end