# encoding: utf-8

lib = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require "star"

$downloaded_song = []

star = Star.new

Shoes.app :title => "Star", :width => 320 do

  stack :margin => 10 do

    stack :margin => 10 do
      para "Username:"
      @username = edit_line
    end

    stack :margin => 10 do
      para "Password:"
      @password = edit_line :secret => true
    end

    stack :margin => 10 do
      para "Captcha:"
      @image_stack = stack :margin_bottom => 10 do
        image download_captcha(star.captcha)
      end
      @captcha = para = edit_line
    end

    stack :margin => 10 do
      para "How many songs do you want?"
      $download_count = edit_line
    end

    stack :margin => 10 do
      button "Save to...." do
        @save_path = ask_open_folder
      end
    end

    stack :margin => 10 do
      button "Login" do
        login = star.login(@username.text, @password.text, @captcha.text)
        if !login
          alert(star.login_error)
          @image_stack.clear do
            image download_captcha(star.captcha)
          end
        end
        while !download_enough?
          star.songs.each do |song|
            if !$downloaded_song.include?(song.sid) && !download_enough?
              puts "Downloading 《#{song.title} - #{song.artist}》..."
              song.save_to(@save_path)
              $downloaded_song << song.sid
            end
          end
        end

        puts "Downloaded #{$downloaded_song.count} songs."
      end
    end

  end

end

def download_captcha(url)
  tmp_file = "/tmp/star-captcha-#{Time.now.to_i}.jpg"
  res = Star.connection(url).get
  File.open(tmp_file, "wb") do |f|
    f.write res.body
  end
  tmp_file
end

def download_enough?
  $downloaded_song.count >= $download_count.text.to_i
end
