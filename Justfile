install:
    bundle install

run:
    bundle exec ruby main.rb

format-code +files="":
    bundle exec standardrb --fix {{files}}
