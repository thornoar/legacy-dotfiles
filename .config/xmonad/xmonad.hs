	-- Base
import XMonad
import qualified XMonad.StackSet as W
import System.Exit

    -- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.Minimize
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Maybe (isJust)
-- import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.InsertPosition

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Minimize
import qualified XMonad.Layout.BoringWindows as BW

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
import XMonad.Prompt.Man
import XMonad.Prompt.Shell
import XMonad.Prompt.XMonad
import Control.Arrow (first)

   -- Utilities
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP)

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "firefox"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth :: Dimension
myBorderWidth = 0

myModMask :: KeyMask
myModMask = mod4Mask

configDir :: String
configDir = "/home/ramak/.config/xmonad/"

myStartupHook :: X ()
myStartupHook = do
	spawnOnce $ configDir ++ "start.sh"
	spawnOnce "feh --randomize --bg-fill /home/ramak/media/JapanWallpapers"  -- feh set random wallpaper

myWorkspaces :: [String]
myWorkspaces = [" 1 ", " 2 ", " 3 "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

myFont :: String
-- myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"
myFont = "xft:Hack Mono:regular:size=10:antialias=true:hinting=true"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

archwiki, news, reddit :: S.SearchEngine
archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
news     = S.searchEngine "news" "https://news.google.com/search?q="
reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="

searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
             , ("g", S.google)
             , ("h", S.hoogle)
             , ("i", S.images)
             , ("n", news)
             , ("r", reddit)
             , ("s", S.stackage)
             , ("t", S.thesaurus)
             , ("v", S.vocabulary)
             , ("w", S.wikipedia)
             , ("y", S.youtube)
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

myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
     map (first $ (,) controlMask)      -- control + <key>
     [ (xK_z, killBefore)               -- kill line backwards
     , (xK_x, killAfter)                -- kill line forwards
     , (xK_Home, startOfLine)              -- move to the beginning of the line
     , (xK_End, endOfLine)                -- move to the end of the line
     , (xK_Left, moveCursor Prev)          -- move cursor forward
     , (xK_Right, moveCursor Next)          -- move cursor backward
     , (xK_BackSpace, killWord Prev)    -- kill the previous word
     , (xK_v, pasteString)              -- paste a string
     ]
     ++
     map (first $ (,) myModMask)          -- meta key + <key>
     [ (xK_BackSpace, killWord Prev)    -- kill the prev word
     , (xK_c, quit)                     -- quit out of prompt
     , (xK_f, moveWord Next)            -- move a word forward
     , (xK_b, moveWord Prev)            -- move a word backward
     , (xK_d, killWord Next)            -- kill the next word
     , (xK_n, moveHistory W.focusUp')   -- move up thru history
     , (xK_p, moveHistory W.focusDown') -- move down thru history
     ]
     ++
     map (first $ (,) 0) -- <key>
     [ (xK_Return, setSuccess True >> setDone True)
     , (xK_KP_Enter, setSuccess True >> setDone True)
     , (xK_BackSpace, deleteString Prev)
     , (xK_Delete, deleteString Next)
     , (xK_Left, moveCursor Prev)
     , (xK_Right, moveCursor Next)
     , (xK_Home, startOfLine)
     , (xK_End, endOfLine)
     , (xK_Down, moveHistory W.focusUp')
     , (xK_Up, moveHistory W.focusDown')
     , (xK_Escape, quit)
     ]

myXPConfig :: XPConfig
myXPConfig = def
      { font                = myFont
      , bgColor             = "#282c34"
      , fgColor             = "#bbc2cf"
      , bgHLight            = "#c792ea"
      , fgHLight            = "#000000"
      , borderColor         = "#535974"
      , promptBorderWidth   = 0
      , promptKeymap        = myXPKeymap
      , position            = Top
      , height              = 30
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Nothing  -- set Just 100000 for .1 sec
      , showCompletionOnTab = False
      , defaultPrompter     = id $ map toUpper  -- change prompt to UPPER
      , alwaysHighlight     = True
      , maxComplRows        = Just 5      -- set to 'Just 5' for 5 rows
      }

myKeys :: [(String, X ())]
myKeys = [
    -- Xmonad
        ("M-M1-<Home>", spawn (myTerminal ++ " --hold -e sh -c 'xmonad --recompile; xmonad --restart; echo Done!'")) -- Recompiles xmonad

    -- Run Prompt
        , ("M-<Return>", shellPrompt myXPConfig) -- Xmonad Shell Prompt

    -- Other Prompts
        , ("M-v m", manPrompt myXPConfig)          -- manPrompt
        , ("M-v x", xmonadPrompt myXPConfig)       -- xmonadPrompt

    -- Useful programs to have a keybinding for launch
        , ("M-v b", spawn (myTerminal ++ " -e btop"))

    -- Kill windows
        , ("M-c", kill)     -- Kill the currently focused client
        , ("M-M1-a", killAll)   -- Kill all windows on current workspace

	-- Quick Programs
		, ("M-e", spawn ( myTerminal ++ " -e ranger" ))
		, ("M-x", spawn ( myTerminal ++ " -e nvim" ))
		, ("M-w", spawn myBrowser)
		, ("M-a", spawn myTerminal)
	
    -- Workspaces
	    , ("M-<Page_Down>", nextWS)
		, ("M-<Page_Up>", prevWS)
		, ("M-M1-<Page_Down>", do
			shiftToNext
  			nextWS
  		)
		, ("M-M1-<Page_Up>", do
			shiftToPrev
			prevWS
  		)

    -- Windows navigation
		, ("M-<Down>", sendMessage $ Go D)
		, ("M-<Up>", sendMessage $ Go U)
		, ("M-<Left>", sendMessage $ Go L)
		, ("M-<Right>", sendMessage $ Go R)
		, ("M-/", windows W.focusDown)
		, ("M-M1-<Left>", windows W.swapMaster)
		, ("M-M1-<Down>", windows W.swapDown)
		, ("M-M1-<Up>", windows W.swapUp)
        , ("M-M1-<Right>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
		, ("M-C-<Left>", windows W.focusUp)
		, ("M-C-<Right>", windows W.focusDown)
		, ("M-d", withFocused minimizeWindow)
		, ("M-b", withLastMinimized maximizeWindow)

    -- Layouts
        , ("M-S-<Down>", sendMessage NextLayout)           -- Switch to next layout
        , ("M-S-<Up>", sendMessage FirstLayout)           -- Switch to next layout
		, ("M-S-/", sendMessage (MT.Toggle NBFULL)) -- Toggles noborder
		-- , ("M-t", sendMessage ToggleStruts)

    -- Increase/decrease windows in the master pane or the stack
        , ("M-S-,", sendMessage (IncMasterN 1))      -- Increase number of clients in master pane
        , ("M-S-.", sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
        -- , ("M-C-<Up>", increaseLimit)                   -- Increase number of windows
        -- , ("M-C-<Down>", decreaseLimit)                 -- Decrease number of windows

    -- Window resizing
        , ("M-C-,", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-C-.", sendMessage Expand)                   -- Expand horiz window width
        , ("M-C-'", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-C-;", sendMessage MirrorExpand)          -- Expand vert window width

	-- Keyboard Layouts
		, ("M-1", spawn "setxkbmap -layout us")
		, ("M-2", spawn "setxkbmap -layout ru")
		, ("M-3", spawn "setxkbmap -layout de")

    -- Multimedia Keys
		, ("M-C-<Page_Down>", spawn "amixer -D pipewire sset Master 5%-")
		, ("M-C-<Page_Up>", spawn "amixer -D pipewire sset Master 5%+")
		, ("M-S-<Right>", spawn "playerctl next")
		, ("M-S-<Left>", spawn "playerctl previous")
		, ("M-<Space>", spawn "playerctl play-pause")

    -- Floating windows
        , ("M-S-<Page_Up>", sendMessage (T.Toggle "simplestFloat")) -- Toggles my 'floats' layout
        , ("M-S-<Page_Down>", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t", sinkAll)                       -- Push ALL floating windows to tile

	-- Special
		-- , ("M-l", spawn "xdotool key Right")
		-- , ("M-k", spawn "xdotool key Left")
        ]
    -- Appending search engine prompts to keybindings list.
    -- Look at "search engines" section of this config for values for "k".
        ++ [("M-f " ++ k, S.promptSearch myXPConfig f) | (k,f) <- searchList ]
        ++ [("M-S-f " ++ k, S.selectSearch f) | (k,f) <- searchList ]

------------------------------------------------------------------------
-- Layouts:

myLayout = tall ||| Full ||| magnified ||| tabs

tall     = windowNavigation
           $ limitWindows 5
           $ mySpacing 0
           $ ResizableTall 1 (3/100) (1/2) []
magnified = windowNavigation
           $ magnifier
           $ limitWindows 12
           $ ResizableTall 1 (3/100) (1/2) []
monocle = windowNavigation
           $ limitWindows 20 Full
grid = windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 0
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals = mySpacing 0
		   $ windowNavigation
		   $ spiral (6/7)
threeCol = windowNavigation
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
tabs = windowNavigation $ tabbed shrinkText myTabTheme

------------------------------------------------------------------------
-- Window rules:

myManageHook = insertPosition Below Newer

------------------------------------------------------------------------
-- Event handling

myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

myLogHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

main = xmonad defaults

defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        layoutHook         = minimize . BW.boringWindows $ myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
		logHook = myLogHook,
        startupHook        = myStartupHook
    } `additionalKeysP` myKeys
