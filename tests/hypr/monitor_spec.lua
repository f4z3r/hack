--# selene: allow(undefined_variable, incorrect_standard_library_use)

local monitor = require("hack.hypr.monitor")

context("Hyprland", function()
  describe("Monitor", function()
    local json = [=[[{
        "id": 1,
        "name": "eDP-1",
        "description": "Philips Consumer Electronics Company PHL 275B1 UK02132051924",
        "make": "Philips Consumer Electronics Company",
        "model": "PHL 275B1",
        "serial": "UK02132051924",
        "width": 2880,
        "height": 1920,
        "physicalWidth": 600,
        "physicalHeight": 340,
        "refreshRate": 59.95100,
        "x": 0,
        "y": 0,
        "activeWorkspace": {
            "address": "6",
            "id": 6,
            "type": "normal",
            "name": "6"
        },
        "specialWorkspace": {
            "address": "",
            "type": "",
            "name": ""
        },
        "reserved": [0, 24, 0, 0],
        "scale": 1,
        "transform": 0,
        "focused": false,
        "dpmsStatus": true,
        "vrr": false,
        "solitary": "0",
        "solitaryBlockedBy": ["WINDOWED","CANDIDATE"],
        "activelyTearing": false,
        "tearingBlockedBy": ["NOT_TORN","USER","CANDIDATE"],
        "directScanoutTo": "0",
        "directScanoutBlockedBy": ["USER","CANDIDATE"],
        "disabled": false,
        "currentFormat": "XRGB8888",
        "mirrorOf": "none",
        "availableModes": ["2560x1440@59.95Hz","2560x1440@74.97Hz","1920x1080@74.97Hz","1920x1080@60.00Hz","1920x1080@60.00Hz","1920x1080@59.94Hz","1920x1080@50.00Hz","1680x1050@59.95Hz","1280x1024@75.03Hz","1280x1024@60.02Hz","1440x900@59.89Hz","1280x960@60.00Hz","1280x720@60.00Hz","1280x720@60.00Hz","1280x720@59.94Hz","1280x720@50.00Hz","1024x768@75.03Hz","1024x768@70.07Hz","1024x768@60.00Hz","832x624@74.55Hz","800x600@75.00Hz","800x600@72.19Hz","800x600@60.32Hz","800x600@56.25Hz","720x576@50.00Hz","720x576@50.00Hz","720x480@60.00Hz","720x480@60.00Hz","720x480@59.94Hz","720x480@59.94Hz","640x480@75.00Hz","640x480@72.81Hz","640x480@66.67Hz","640x480@60.00Hz","640x480@59.94Hz","640x480@59.94Hz","720x400@70.08Hz"],
        "colorManagementPreset": "srgb",
        "sdrBrightness": 1,
        "sdrSaturation": 1,
        "sdrMinLuminance": 0.2,
        "sdrMaxLuminance": 80,
        "hardwareCursorsInUse": true,
        "hardwareDetails": {
            "backend": "drm",
            "hdr": false,
            "chroma": true,
            "bt2020": false,
            "vrrCapable": false
        }
    },{
        "id": 2,
        "name": "DP-2",
        "description": "Philips Consumer Electronics Company PHL 275B1 UK02132051924",
        "make": "Philips Consumer Electronics Company",
        "model": "PHL 275B1",
        "serial": "UK02132051924",
        "width": 2560,
        "height": 1440,
        "physicalWidth": 600,
        "physicalHeight": 340,
        "refreshRate": 59.95100,
        "x": 2560,
        "y": 0,
        "activeWorkspace": {
            "address": "6",
            "id": 6,
            "type": "normal",
            "name": "6"
        },
        "specialWorkspace": {
            "address": "",
            "type": "",
            "name": ""
        },
        "reserved": [0, 24, 0, 0],
        "scale": 1,
        "transform": 0,
        "focused": false,
        "dpmsStatus": true,
        "vrr": false,
        "solitary": "0",
        "solitaryBlockedBy": ["WINDOWED","CANDIDATE"],
        "activelyTearing": false,
        "tearingBlockedBy": ["NOT_TORN","USER","CANDIDATE"],
        "directScanoutTo": "0",
        "directScanoutBlockedBy": ["USER","CANDIDATE"],
        "disabled": false,
        "currentFormat": "XRGB8888",
        "mirrorOf": "none",
        "availableModes": ["2560x1440@59.95Hz","2560x1440@74.97Hz","1920x1080@74.97Hz","1920x1080@60.00Hz","1920x1080@60.00Hz","1920x1080@59.94Hz","1920x1080@50.00Hz","1680x1050@59.95Hz","1280x1024@75.03Hz","1280x1024@60.02Hz","1440x900@59.89Hz","1280x960@60.00Hz","1280x720@60.00Hz","1280x720@60.00Hz","1280x720@59.94Hz","1280x720@50.00Hz","1024x768@75.03Hz","1024x768@70.07Hz","1024x768@60.00Hz","832x624@74.55Hz","800x600@75.00Hz","800x600@72.19Hz","800x600@60.32Hz","800x600@56.25Hz","720x576@50.00Hz","720x576@50.00Hz","720x480@60.00Hz","720x480@60.00Hz","720x480@59.94Hz","720x480@59.94Hz","640x480@75.00Hz","640x480@72.81Hz","640x480@66.67Hz","640x480@60.00Hz","640x480@59.94Hz","640x480@59.94Hz","720x400@70.08Hz"],
        "colorManagementPreset": "srgb",
        "sdrBrightness": 1,
        "sdrSaturation": 1,
        "sdrMinLuminance": 0.2,
        "sdrMaxLuminance": 80,
        "hardwareCursorsInUse": true,
        "hardwareDetails": {
            "backend": "drm",
            "hdr": false,
            "chroma": true,
            "bt2020": false,
            "vrrCapable": false
        }
    }]]=]

    it("can be created from a hyprctl JSON output", function()
      local monitors = monitor.Monitor:from_hyprctl(json)
      assert.are.equal(2, #monitors)
      local mon = monitors[2]
      assert.are.equal(2, mon.id)
      assert.are.equal(2560, mon.resolution.x)
      assert.are.equal("DP-2", mon.name)
      assert.are.equal(false, mon.flipped)
    end)

    it("can be moved to the right", function()
      local monitors = monitor.Monitor:from_hyprctl(json)
      local position = monitors[2]:right_of(monitors[1])
      assert.are.equal(2880, position.x)
      assert.are.equal(0, position.y)
    end)

    it("can be moved above", function()
      local monitors = monitor.Monitor:from_hyprctl(json)
      local position = monitors[2]:above(monitors[1])
      assert.are.equal(0, position.x)
      assert.are.equal(-1440, position.y)
    end)
  end)
end)
