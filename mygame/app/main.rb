def tick args
  #if Kernel.tick_count > 518
  #  puts "#{args.state.dvd}"
  #  GTK.slowmo! 30
  #end
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 221,
    g: 226,
    b: 226,
  }

  args.state.dvd ||= { x: 640,
                       y: 360,
                       w: 73,
                       h: 89,
                       path: "sprites/AstroGuy.png",
                       dx: 5,
                       dy: 5,
                       collision_x: false,
                       collision_y: false, }

  args.state.boundaries ||= [
    { target_w: 5, growth_direction: :x, apply_offset: false, x: 0, y: 0, w: 5, h: 720, path: :solid, r: 0, g: 0, b: 0 },
    { target_w: 5, growth_direction: :x, apply_offset: true, x: 1275, y: 0, w: 5, h: 720, path: :solid, r: 0, g: 0, b: 0 },
    { target_h: 5, growth_direction: :y, apply_offset: false, x: 0, y: 0, w: 1280, h: 5, path: :solid, r: 0, g: 0, b: 0 },
    { target_h: 5, growth_direction: :y, apply_offset: true, x: 0, y: 715, w: 1280, h: 5, path: :solid, r: 0, g: 0, b: 0 },
  ]

  args.state.moon ||= {
    x: 1142,
    y: 0,
    h: 128,
    w: 128,
    path: 'sprites/Moon.png',
  }

  args.state.moon.alpha ||= 0

  args.state.stars_enabled ||= false
  args.state.last_star_update ||= 0
  args.state.stars ||= []

  args.state.dvd.collision_x = false
  args.state.dvd.collision_y = false

  next_x = args.state.dvd.x + args.state.dvd.dx
  next_y = args.state.dvd.y + args.state.dvd.dy

  future_dvd_x = args.state.dvd.merge(x: next_x)
  future_dvd_y = args.state.dvd.merge(y: next_y)
  
  collision_y = args.state.boundaries.find do |boundary|
    Geometry.intersect_rect?(future_dvd_y, boundary)
  end

  if collision_y
    args.state.dvd.dy *= -1
    args.state.dvd.collision_y = true
  else
    args.state.dvd.y = next_y
  end

  collision_x = args.state.boundaries.find do |boundary|
    Geometry.intersect_rect?(future_dvd_x, boundary)
  end

  if collision_x
    args.state.dvd.dx *= -1
    args.state.dvd.collision_x = true
  else
    args.state.dvd.x = next_x
  end

  args.state.dvd_angle ||= 0
  args.state.dvd_angle += 1

  #args.outputs.watch "#{args.state.dvd}"
  args.outputs.sprites << args.state.boundaries
  args.outputs.sprites << args.state.dvd.merge(angle: args.state.dvd_angle)
  #args.outputs.borders << args.state.dvd.merge(r: 255, g: 0, b: 0)
  
  if args.state.stars_enabled
    if args.tick_count - args.state.last_star_update > 80
      args.state.stars = 5.times.map { spawn_stars(args) }
      args.state.last_star_update = args.tick_count
    end

    args.outputs.sprites << args.state.stars


    args.state.moon.alpha = args.state.moon.alpha.lerp(255, 0.05)
    args.outputs.sprites << args.state.moon.merge(a: args.state.moon.alpha)
  end

  if args.inputs.keyboard.key_down.space
    puts Kernel.tick_count
    args.state.boundaries.each do |boundary|
      if boundary.growth_direction == :x
        boundary.target_w += 5
      elsif boundary.growth_direction == :y
        boundary.target_h += 5
      end
    end
  end

  args.state.boundaries.each do |boundary|
    if boundary.growth_direction == :x
      boundary.w = boundary.w.lerp(boundary.target_w, 0.1)
      if boundary.apply_offset
        boundary.x = 1280 - boundary.w
      end
    end

    if boundary.growth_direction == :y
      boundary.h = boundary.h.lerp(boundary.target_h, 0.1)
      if boundary.apply_offset
        boundary.y = 720 - boundary.h
      end
    end
  end

  if !args.state.stars_enabled
    left   = args.state.boundaries[0][:w]
    right  = args.state.boundaries[1][:w]
    top    = args.state.boundaries[3][:h]
    bottom = args.state.boundaries[2][:h]

    if left >= 80 && right >= 80 && top >= 80 && bottom >= 80
      args.state.stars_enabled = true
      args.state.stars = 5.times.map { spawn_stars(args) }
      args.state.last_star_update = args.tick_count
    end
  end
end

def spawn_stars(args)
  margin = 64

  left   = args.state.boundaries[0][:w]
  right  = args.state.boundaries[1][:w]
  top    = args.state.boundaries[3][:h]
  bottom = args.state.boundaries[2][:h]

  side = [:left, :right, :top, :bottom].sample

  case side
  when :left
    x = rand(left - margin)
    y = rand(720)
  when :right
    x = 1280 - rand(right - margin)
    y = rand(720)
  when :top
    x = rand(1280)
    y = 720 - rand(top - margin)
  when :bottom
    x = rand(1280)
    y = rand(bottom - margin)
  end

  {
    x: x.clamp(0, 1280 - margin),
    y: y.clamp(0, 720 - margin),
    w: 32,
    h: 32,
    path: 'sprites/star2.png',
  }
end
