--
-- xmonad example config file for xmonad-0.9
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
-- NOTE: Those updating from earlier xmonad versions, who use
-- EwmhDesktops, safeSpawn, WindowGo, or the simple-status-bar
-- setup functions (dzen, xmobar) probably need to change
-- xmonad.hs, please see the notes below, or the following
-- link for more details:
--
-- http://www.haskell.org/haskellwiki/Xmonad/Notable_changes_since_0.8
--
import Control.Applicative ((<$>)) -- , liftA2)
import Control.Monad (liftM2, (>=>))
import Data.List (isPrefixOf, nub)

import XMonad
import XMonad.Layout.Grid
import XMonad.Layout.ResizableTile
import XMonad.Layout.IM
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders
import XMonad.Layout.Circle
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Fullscreen
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog
import XMonad.Actions.Plane
import XMonad.Actions.CycleWS
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Actions.CycleWS
import XMonad.Hooks.EwmhDesktops
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myFocusedBorderColor = "#ff0000"      -- color of focused border
myNormalBorderColor  = "#cccccc"      -- color of inactive border
myBorderWidth        = 1              -- width of border around windows
myTerminal           = "terminator"   -- which terminal software to use

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myScreensaver = "xscreensaver-command -lock"

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

myTitleColor     = "#b7e9a0"  -- color of window title
myTitleLength    = 80         -- truncate window title to this length
myCurrentWSColor = "#e6744c"  -- color of active workspace
myVisibleWSColor = "#c185a7"  -- color of inactive workspace
myUrgentWSColor  = "#cc0000"  -- color of workspace with 'urgent' window
myCurrentWSLeft  = "["        -- wrap active workspace with these
myCurrentWSRight = "]"
myVisibleWSLeft  = "("        -- wrap inactive workspace with these
myVisibleWSRight = ")"
myUrgentWSLeft  = "{"         -- wrap urgent workspace with these
myUrgentWSRight = "}"



-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myExtraWorkspaces = [(xK_0, "0"),(xK_minus, "tmp"),(xK_equal, "swap")]
myWorkspaces =
  [
    "1",  "2", "3",
    "4",  "5:LO", "6:Web",
    "7:Music", "8:Chat", "9:Email"
  ] ++ (map snd myExtraWorkspaces)
startupWorkspace = "1"  -- which workspace do you want to be on after launch?


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    , ((modm .|. controlMask, xK_l), spawn myScreensaver)

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm, xK_q), restart "xmonad" True)

    , ((modm .|. controlMask, xK_Right), moveTo Next NonEmptyWS)
    , ((modm .|. controlMask, xK_Left), moveTo Prev NonEmptyWS)

    -- Decrease volume.
    , ((modm .|. controlMask, xK_j),
       spawn "amixer -q set Master 10%-")

    , ((mod4Mask, xK_Down),
       spawn "amixer -q set Master 10%-")

    -- Increase volume.
    , ((modm .|. controlMask, xK_k),
       spawn "amixer -q set Master 10%+")

    , ((mod4Mask, xK_Up),
       spawn "amixer -q set Master 10%+")

    , ((modm .|. controlMask, xK_n),
       spawn "bash ~/workspace/SpotifyController/spotify.sh n > /dev/null")

    , ((modm .|. controlMask, xK_period),
       spawn "bash ~/workspace/SpotifyController/spotify.sh n > /dev/null")

    , ((mod4Mask, xK_Right),
       spawn "bash ~/workspace/SpotifyController/spotify.sh n > /dev/null")

    , ((modm .|. controlMask, xK_p),
       spawn "bash ~/workspace/SpotifyController/spotify.sh p > /dev/null")

    , ((mod4Mask, xK_Left),
       spawn "bash ~/workspace/SpotifyController/spotify.sh p > /dev/null")

    , ((modm .|. controlMask, xK_comma),
       spawn "bash ~/workspace/SpotifyController/spotify.sh p > /dev/null")

    , ((mod4Mask, xK_space),
       spawn "bash ~/workspace/SpotifyController/spotify.sh pause > /dev/null")

    , ((modm .|. controlMask, xK_space),
       spawn "bash ~/workspace/SpotifyController/spotify.sh pause > /dev/null")

    , ((modm .|. controlMask, xK_s),
       spawn "sudo /usr/sbin/pm-suspend")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    [
        ((myModMask, key), (windows $ W.greedyView ws))
        | (key,ws) <- myExtraWorkspaces
      ] ++ [
        ((myModMask .|. shiftMask, key), (windows $ W.shift ws))
        | (key,ws) <- myExtraWorkspaces
      ]
    ++
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- Instead use the 'ewmh' function from that module to modify your
-- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--myLayout = smartBorders(avoidStruts(tiled ||| Mirror tiled ||| Full))
myLayout = smartBorders(avoidStruts(
  -- ResizableTall layout has a large master window on the left,
  -- and remaining windows tile on the right. By default each area
  -- takes up half the screen, but you can resize using "super-h" and
  -- "super-l".
  ResizableTall 1 (3/100) (1/2) []

  -- Mirrored variation of ResizableTall. In this layout, the large
  -- master window is at the top, and remaining windows tile at the
  -- bottom of the screen. Can be resized as described above.
  ||| Mirror (ResizableTall 1 (3/100) (1/2) [])

  -- Full layout makes every window full screen. When you toggle the
  -- active window, it will bring the active window to the front.
  ||| noBorders Full))

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManagementHooks :: [ManageHook]
myManagementHooks = [
  resource =? "synapse" --> doIgnore
  , resource =? "stalonetray" --> doIgnore
  , className =? "rdesktop" --> doFloat
  , ("libreoffice" `isPrefixOf`) <$> className --> doF (W.shift "5:LO")
  , (className =? "google-chrome") --> doF (W.shift "6:Web")
  , (className =? "Google-chrome") --> doF (W.shift "6:Web")
  , (className =? "vivaldi-stable") --> doF (W.shift "6:Web")
  , (className =? "Vivaldi-stable") --> doF (W.shift "6:Web")
  , (className =? "Spotify") --> doF (W.shift "7:Music")
  , (className =? "spotify") --> doF (W.shift "7:Music")
  , (className =? "Pidgin") --> doF (W.shift "8:Chat")
  , (className =? "HipChat") --> doF (W.shift "8:Chat")
  , (className =? "Slack") --> doF (W.shift "8:Chat")
  , (className =? "Thunderbird") --> doF (W.shift "9:Email")
  ]

------------------------------------------------------------------------
-- Event handling

-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
--myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
--myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
myStartupHook = do
            windows $ W.greedyView startupWorkspace
            spawn "~/.xmonad/startup-hook"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ ewmh $ docks def {
    focusedBorderColor = myFocusedBorderColor
  , focusFollowsMouse  = myFocusFollowsMouse
  , normalBorderColor = myNormalBorderColor
  , terminal = myTerminal
  , borderWidth = myBorderWidth
  , layoutHook = myLayout
  , workspaces = myWorkspaces
    ,keys               = myKeys
--  , modMask = myModMask
--  , handleEventHook = fullscreenEventHook
  , handleEventHook = mconcat
                    [ docksEventHook
                    , handleEventHook defaultConfig ]
  , startupHook = do
      windows $ W.greedyView startupWorkspace
      spawn "~/.xmonad/startup-hook"
  , manageHook = manageHook defaultConfig
      <+> composeAll myManagementHooks
      <+> manageDocks
  , logHook = dynamicLogWithPP $ xmobarPP {
      ppOutput = hPutStrLn xmproc
      , ppTitle = xmobarColor myTitleColor "" . shorten myTitleLength
      , ppCurrent = xmobarColor myCurrentWSColor ""
        . wrap myCurrentWSLeft myCurrentWSRight
      , ppVisible = xmobarColor myVisibleWSColor ""
        . wrap myVisibleWSLeft myVisibleWSRight
      , ppUrgent = xmobarColor myUrgentWSColor ""
        . wrap myUrgentWSLeft myUrgentWSRight
    }
  }
    `additionalKeys`
    [((0, 0x1008FF12), spawn "amixer -q set Master toggle")
    , ((0, 0x1008FF11), spawn "amixer -q set Master 10%-")
    , ((0, 0x1008FF13), spawn "amixer -q set Master 10%+")
    --, ((0, 0x1008FF02), spawn "xbacklight -inc 10")
    --, ((0, 0x1008FF03), spawn "xbacklight -dec 10")
    , ((0, 0x1008FF02), spawn "xrandr --output eDP-1-1 --brightness $(xrandr --current --verbose | grep -i brightness | awk '{print $2}' | python -c 'import sys; foo = float(sys.stdin.read()); print(foo + .1)')")
    , ((0, 0x1008FF03), spawn "xrandr --output eDP-1-1 --brightness $(xrandr --current --verbose | grep -i brightness | awk '{print $2}' | python -c 'import sys; foo = float(sys.stdin.read()); print(foo - .1)')")
    , ((0, 0x1008FF17), spawn "bash ~/workspace/SpotifyController/spotify.sh n > /dev/null")
    , ((0, 0x1008FF16), spawn "bash ~/workspace/SpotifyController/spotify.sh p > /dev/null")
    , ((0, 0x1008FF14), spawn "bash ~/workspace/SpotifyController/spotify.sh pause > /dev/null")
    , ((0, 0x1008FF15), spawn "spotify & > /dev/null")
    ]
