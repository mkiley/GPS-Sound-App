-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
--hides status bar
display.setStatusBar( display.HiddenStatusBar )

system.setLocationAccuracy( .001 )  -- set GPS accuracy to 1 meters. How do you test this?

--system.setLocationThreshold( 100 )  -- fire the location event every 100 meters
--mySound4 = audio.loadSound( "dingdong4.aif" ),
--mySound5 = audio.loadSound( "dingdong5.aif" ),

--lables that show each parameter on screen of device.
local latitude = display.newText( "-", 100, 50, native.systemFont, 16 )
local longitude = display.newText( "-", 100, 100, native.systemFont, 16 )
local altitude = display.newText( "-", 100, 150, native.systemFont, 16 )
local accuracy = display.newText( "-", 100, 200, native.systemFont, 16 )
local speed = display.newText( "-", 100, 250, native.systemFont, 16 )
local direction = display.newText( "-", 100, 300, native.systemFont, 16 )
local time = display.newText( "-", 100, 350, native.systemFont, 16 )


local previous_zone = 0


--declaring zones of location and their parameters.
local zones = {
	{
		lat = 39.9566023,--Science Center Door
		lng = -75.1966792,
		radius = .0005,
		sound = audio.loadSound( "dingdong1.aif" ),
        channel = 1,
	},
	{
		lat = 39.9565529,--DM+D Door
		lng = -75.1962018,
		radius = .0005,
		sound = audio.loadSound( "dingdong2.aif" ),
        channel = 2,
	},
	{
		lat = 39.9564974,--Yellow mums
		lng = -75.1956654,
		radius = .0005,
		sound = audio.loadSound( "dingdong3.aif" ),
        channel = 3,
	},
}
--The Handler. A handler and a call back is the same this. This is a grouping of code that gets named so that you can call it later. A callback is a function, but a function is not necessarily a callback.
--its a call back if it is triggered by some event.

local locationHandler = function( event )

    -- Check for error (user may have turned off location services)
    if ( event.errorCode ) then
        native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
        print( "Location error: " .. tostring( event.errorMessage ) )
    else
        latitude.text = string.format( 'lat %.7f', event.latitude )--give lat location and turns it into text that we can assign to the lable

        longitude.text = string.format('long %.7f', event.longitude )--give long location.

        -- local altitudeText = string.format( '%.3f', event.altitude )
        -- altitude.text = altitudeText

        -- local accuracyText = string.format( '%.3f', event.accuracy )
        -- accuracy.text = accuracyText

        -- local speedText = string.format( '%.3f', event.speed )
        -- speed.text = speedText

        -- local directionText = string.format( '%.3f', event.direction )
        -- direction.text = directionText

        -- -- Note that 'event.time' is a Unix-style timestamp, expressed in seconds since Jan. 1, 1970
        -- local timeText = string.format( '%.0f', event.time )
        -- time.text = timeText
--which zone I am inside of if any.
        local inside_zone_idx = 0
        --ipairs gives you an index and the table values of the zones table for each index.
        for idx, zone in ipairs(zones) do
        	if in_rectangle(zone.lng, zone.lat, zone.radius, event.longitude, event.latitude) then
        		inside_zone_idx = idx
        	end
        end
--what zone am I clsoest to
        local closest_zone_idx = 0
        local shortest_distance = 1000
        --ipairs gives you an index and the table values of the zones table for each index.
        for idx, zone in ipairs(zones) do
            if get_distance(zone.lng, zone.lat, event.longitude, event.latitude) < shortest_distance then
                closest_zone_idx = idx
                shortest_distance = get_distance(zone.lng, zone.lat, event.longitude, event.latitude)
            end
        end


--this variable, zone, is saying if we are in a zone, print which one, OR exit the callback.
        --[[local zone 
        if inside_zone_idx > 0 then
            zone = zones[inside_zone_idx]
            time.text = "inside zone " .. inside_zone_idx 
        else
        	time.text = "not inside any zone"
            return--because this return si there, we can assume that the code below it is going to have a zone.
        end--]]

--this variable, zone, is finding the closest distance and making sure that sound doesnt play if I am out of a cutoff radius.
        local zone 
        if closest_zone_idx > 0 and shortest_distance < .01 then
            zone = zones[closest_zone_idx]
            time.text = "closest zone " .. closest_zone_idx
        else
            time.text = "not inside any zone"
            return--because this return is there, we can assume that the code below it is going to have a zone.
        end




--have sound only play once at a time
        if audio.isChannelPlaying(zone.channel) then
            previous_zone = zone.channel 
            return true
        --[[else if previous_zone == 1 and zone.channel == 2 then
            audio.fadeOut( { channel = 0, time = 0})
            audio.play( zone.sound, {channel = zone.channel, loops = -1, fadein = 0} ) --]]  
        else
            audio.fadeOut(  { channel = previous_zone, time=2000 }  )
            audio.setVolume( 1.0 , { channel = zone.channel } )
            audio.play( zone.sound, {channel = zone.channel, loops = -1, fadein = 2000} )
        end
        previous_zone = zone.channel 
    end
end


-- Activate location listener
Runtime:addEventListener( "location", locationHandler )
--cx is zone location, x is phone location
function in_rectangle(cx, cy, r, x, y)
	local distance = math.sqrt((cx - x) ^ 2 + (cy - y) ^ 2)
    --print (distance)
	if distance < r then
		return true
	else
		return false
	end
end

function get_distance(cx, cy, x, y)
    local distance = math.sqrt((cx - x) ^ 2 + (cy - y) ^ 2)
    print (" distance equals " .. (distance))
    return distance
end





