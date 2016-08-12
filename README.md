# GTAlertBar

A no-nonsense manager for showing alert bars on iOS apps.

<img src="http://i.imgur.com/Dh6VGyg.gif" />

Are you tired of dealing with terrible alert bar managers that lock you into
fixed colors, don't let you change images, or ever let you dismiss the bars
progmatically?

Not anymore you're not! Because now you've found GTAlertBar, which if I might
say so myself, is just simply the best alert bar manager on the market.

# Using it

## Install it

Installation is easy! Insert disk 1 out of 15 and ensure you have your
SoundBlaster audio device configured.

**Pop this sucker into your Podfile:**

```
target 'YourSlickApp' do
    use_frameworks!

    pod 'GTAlertBar'
end
```

## Configure it

GTAlertBar is designed to be very customizable to suite all your alert bar
needs!

All configuration options are kept neatly inside of the `GTAlertBarOptions`
class.

**For full configuration documentation see the [Configuration wiki page](https://github.com/ecnepsnai/GTAlertBar/wiki/Configuration)**

### Specify a background color
```swift
let options = GTAlertBarOptions()
options.colors.background = UIColor.redColor()
```

### Include an optional image
```swift
let options = GTAlertBarOptions()
options.image = UIImage(named: "myImage.png")
```

#### Optionally, use the included images
```swift
let options = GTAlertBarOptions()
options.image = GTAlertBarImage.exclamation
options.image = GTAlertBarImage.info
options.image = GTAlertBarImage.caution
options.image = GTAlertBarImage.check
```

## Show it

```swift
GTAlertBar.barAttachedToView(self,
    title: "Alert Title",
    body: "Optional alert body",
    options: options)
```

## Hide it

```swift
let bar = GTAlerBar.barAttachedToView...
bar.removeFromParentView()
```
