-- Base
import Data.Monoid
import XMonad
import System.Directory
import System.IO (hClose, hPutStr, hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
import System.Exit

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS
-- import XMonad.Actions.Volume
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.InsertPosition
-- import XMonad.Hooks.RefocusLast

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Prompts
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Unicode
import XMonad.Prompt.XMonad
import Control.Arrow (first)

   -- Utilities
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook, trayerPaddingXmobarEventHook, trayPaddingXmobarEventHook, trayPaddingEventHook)
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Themes

myTerminal :: String
myTerminal = "alacritty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth :: Dimension
myBorderWidth = 0

myModMask :: KeyMask
myModMask = mod4Mask

myStartupHook :: X ()
myStartupHook = do
	spawn "keynav&"
	spawn "unclutter -idle 2.0&"
	spawn "xset r rate 200 30"
	-- spawnOnce "feh --randomize --bg-fill /usr/share/backgrounds/dtos-backgrounds/*"  -- feh set random wallpaper

myWorkspaces :: [String]
myWorkspaces = [" web ", " dev ", " media ", " sys ", " aux "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

archwiki, ebay, news, reddit, urban, yacy :: S.SearchEngine
archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
ebay     = S.searchEngine "ebay" "https://www.ebay.com/sch/i.html?_nkw="
news     = S.searchEngine "news" "https://news.google.com/search?q="
reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="
urban    = S.searchEngine "urban" "https://www.urbandictionary.com/define.php?term="
yacy     = S.searchEngine "yacy" "http://localhost:8090/yacysearch.html?query="

searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
             , ("d", S.duckduckgo)
             , ("e", ebay)
             , ("g", S.google)
             , ("h", S.hoogle)
             , ("i", S.images)
             , ("n", news)
             , ("r", reddit)
             , ("s", S.stackage)
             , ("t", S.thesaurus)
             , ("v", S.vocabulary)
             , ("b", S.wayback)
             , ("u", urban)
             , ("w", S.wikipedia)
             , ("y", S.youtube)
             , ("S-y", yacy)
             , ("z", S.amazon)
             ]

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $ [ 
		((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
		-- Kill focused window
		((modm, xK_c), kill),
		-- Rotate through the available layout algorithms
		((modm .|. shiftMask, xK_Down), sendMessage NextLayout),
		--  Reset the layouts on the current workspace to default
		((modm .|. shiftMask, xK_Up), setLayout $ XMonad.layoutHook conf),
		-- Resize viewed windows to the correct size
		((modm, xK_n), refresh),
		-- Move focus to the next window
		((modm, xK_Down), sendMessage $ Go D),
		-- Move focus to the previous window
		((modm, xK_Up), sendMessage $ Go U),
		-- Move focus to the master window
		((modm, xK_Left), sendMessage $ Go L),
		-- Move focus back to previous window
		((modm, xK_Right), sendMessage $ Go R),
		-- Cycle through windows
		((modm, xK_slash), windows W.focusDown),
		-- Swap the focused window and the master window
		((modm .|. mod1Mask, xK_Left), windows W.swapMaster),
		-- Swap the focused window with the next window
		((modm .|. mod1Mask, xK_Down), windows W.swapDown),
		-- Swap the focused window with the previous window
		((modm .|. mod1Mask, xK_Up), windows W.swapUp),
		-- Shrink the master area
		((modm .|. shiftMask, xK_comma), sendMessage Shrink),
		-- Expand the master area
		((modm .|. shiftMask, xK_period), sendMessage Expand),
		-- Push window back into tiling
		((modm, xK_t), withFocused $ windows . W.sink),
		-- Increment the number of windows in the master area
		((modm, xK_comma), sendMessage (IncMasterN 1)),
		-- Deincrement the number of windows in the master area
		((modm, xK_period), sendMessage (IncMasterN (-1))),
		-- Restart xmonad
		((modm .|. mod1Mask, xK_Home), spawn "xmonad --recompile; xmonad --restart"),
		-- Workspaces
		((modm, xK_Page_Down), nextWS),
		((modm, xK_Page_Up), prevWS),
		((modm .|. mod1Mask, xK_Page_Down), do
			shiftToNext
  			nextWS
  		),
		((modm .|. mod1Mask, xK_Page_Up), do
			shiftToPrev
			prevWS
  		),
		((modm, xK_e), spawn ( myTerminal ++ " -e ranger" )),
		((modm, xK_x), spawn ( myTerminal ++ " -e nvim" )),

		-- Media
		((modm .|. shiftMask, xK_Right), spawn "playerctl next"), 
		((modm .|. shiftMask, xK_Left), spawn "playerctl previous"),
		((modm, xK_space), spawn "playerctl play-pause"),
	
		-- Language layouts
		((modm, xK_1), spawn "setxkbmap -layout us"),
		((modm, xK_2), spawn "setxkbmap -layout ru"),
		((modm, xK_3), spawn "setxkbmap -layout de"),
		
		-- Volume
		((modm .|. shiftMask, xK_Page_Down), spawn "amixer -q sset Master 5%-"),
		((modm .|. shiftMask, xK_Page_Up), spawn "amixer -q sset Master 5%+"),

		-- Prompt scripts
		((modm, xK_Return), spawn "dmenu_run"),
		-- ((modm, xK_v), manPrompt )

		((modm, xK_a), spawn myTerminal)
	]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.


-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.

myLayout = tall ||| Full ||| magnified

tall     = renamed [Replace "tall"]
           $ windowNavigation
           -- $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ limitWindows 5
           $ mySpacing 0
           $ ResizableTall 1 (3/100) (1/2) []
magnified  = renamed [Replace "magnify"]
           $ windowNavigation
           -- $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           -- $ mySpacing 3
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           -- $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
-- floats   = renamed [Replace "floats"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ limitWindows 20 simplestFloat
-- grid     = renamed [Replace "grid"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ limitWindows 12
--            $ mySpacing 0
--            $ mkToggle (single MIRROR)
--            $ Grid (16/10)
-- spirals  = renamed [Replace "spirals"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ mySpacing' 8
--            $ spiral (6/7)
-- threeCol = renamed [Replace "threeCol"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ limitWindows 7
--            $ ThreeCol 1 (3/100) (1/2)
-- threeRow = renamed [Replace "threeRow"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ limitWindows 7
--            -- Mirror takes a layout and rotates it by 90 degrees.
--            -- So we are applying Mirror to the ThreeCol layout.
--            $ Mirror
--            $ ThreeCol 1 (3/100) (1/2)
-- tabs     = renamed [Replace "tabs"]
--            -- I cannot add spacing to this layout because it will
--            -- add spacing between window and tabs which looks bad.
--            $ tabbed shrinkText myTabTheme

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
myManageHook = insertPosition Below Newer

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = xmonad defaults

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
