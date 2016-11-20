function Initialize()

  -- Imports
  dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
  dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')

  -- Measures
  measureHeroStats = SKIN:GetMeasure('MeasureHeroStats')

  -- Globals
  __Stats = {}
  __HeroStats = {}
  __SelectedHero = ""
  __APIURL = "http://192.168.1.105:8080/owstats"

  -- heroes
  __Heroes = {
      Tracer= {
          type = 'offensive'
      },

      Reaper= {
          type = 'offensive'
      },

      Mercy = {
          type = 'support'
      },

      Lucio = {
          type = 'support'
      },

      Ana = {
          type = 'support'
      }
  }
  __Heroes['D.Va'] = { type = 'tank' }

  SetMeasureURL('MeasureHeroStats', GetAPIURL())
  SelectHero('Tracer')
end

function SelectHero(hero)
    __SelectedHero = hero
    HideGroup('stats')
    if __Stats then
        ParseHeroStats()
    end
end

function ParseHeroStats()
    local raw = measureHeroStats:GetStringValue()
    if raw == '' then
        return false
    end
	
    __Stats = JSONParse(raw)
    __HeroStats = __Stats.Heroes

    ShowGroup('stats')
    SetTitle("MeterStatsHero", __SelectedHero)
    PrintPlayerStats(__Stats.Player)
    PrintSpecialStats(__HeroStats[__SelectedHero])
    PrintNormalStats(__HeroStats[__SelectedHero])
end

function Refresh()
  HideGroup('stats')
  SetMeasureURL('MeasureHeroStats', GetAPIURL())
end

function PrintPlayerStats(playerStats)
    local playerName = playerStats["Name"]
    local skillRating = playerStats["Skill Rating"]
    local skillRank = playerStats["Skill Rank"]
    local winRate = playerStats["Win Rate"]

    SetTitle("MeterPlayerName", playerName)
    SetTitle("MeterSkillRating", skillRating)
    SetTitle("MeterSkillRank", skillRank);
    SetTitle("MeterWinRateOverall", winRate)
end

function PrintSpecialStats(heroStats)
    local heroRank = heroStats["Hero Rank"]["Value"]
    local record = heroStats["Record"]["Value"]
    local winRate = heroStats["Win Rate"]["Value"]

    -- Special Stats
    SetTitle("MeterHeroRank", heroRank)
    SetTitle("MeterRecord", record);
    SetTitle("MeterWinRate", winRate)

    SetTitle("MeterEliminationsAvg", elim)
    SetFormula("MeasureEliminationsPercentile", elimPercentile)

    SetTitle("MeterDamage", dmg)
    SetFormula("MeterDamagePercentile", dmgPercentile)

end

function PrintNormalStats(heroStats)
    local typeStats = GetStats()

    for i, statName in ipairs(typeStats) do
        local statValue = heroStats[statName]["Value"]
        local statPercentile = heroStats[statName]["Percentile"]["Value"]
        local statPercentileText = heroStats[statName]["Percentile"]["Text"]

        SetTitle("MeterStatValue"..i, statValue)
        SetFormula("MeterStatPercentile"..i, statPercentile)
        SetTitle("MeterStatLabel"..i, statName)
        SetTooltipText("MeterStatPercentileBar"..i, statPercentileText)
        PrintTrend(heroStats[statName], i)
    end
end

function PrintTrend(stats, i)
    local trendObj = stats.Trend

    if not trendObj then
        SetImageName("MeterStatTrend"..i, "")
        return
    end

    if trendObj.IsIncreasing then
        if trendObj.IsPositive then
            SetImageName("MeterStatTrend"..i, "Images/UpGood.png")
        else
            SetImageName("MeterStatTrend"..i, "Images/UpBad.png")
        end
        SetTooltipText("MeterStatTrend"..i, trendObj.Text)
    else
        if trendObj.IsPositive then
            SetImageName("MeterStatTrend"..i, "Images/DownGood.png")
        else
            SetImageName("MeterStatTrend"..i, "Images/DownBad.png")
        end
        SetTooltipText("MeterStatTrend"..i, trendObj.Text)
    end
end

function GetStats()
    local stats = {
        offensive = {
            "Eliminations", "Deaths",
            "Damage", "Obj Kills",
            "Weapon Acc", "Critical Hits"
        }, 
        support = {
            "Healing", "Deaths",
            "Def Assists", "Off Assists",
            "Eliminations", "Weapon Acc"
        },
        tank = {
            "Eliminations", "Deaths",
            "Dmg Blocked", "Weapon Acc",
            "Obj Kills", "Obj Time"
        }
    }
    local type = __Heroes[__SelectedHero]["type"]
    local typeStats = stats[type]
    AddHeroSpecificStats(typeStats)
    return typeStats
end

function AddHeroSpecificStats(stats)
    local heroSpecificStats = {
        Tracer = {
            "Bombs Stuck", "Bomb Kills",
        }, 
        Mercy = {
            "Resurrects", "Solo Kills",
        },
        Reaper = {
            "Blossom Kills", "Souls Gained",
        },
        Ana = {
            "Boost Assists", "Enemies Slept",
        },
        Lucio = {
            "Sound Barriers", "Env Kills"
        }
    }
    heroSpecificStats["D.Va"] =  {
        "Destruct Kills", "Mech Recalls",
    }

    local statName1 = heroSpecificStats[__SelectedHero][1]
    local statName2 = heroSpecificStats[__SelectedHero][2]

    table.insert(stats, statName1)
    table.insert(stats, statName2)
end

function ShowTooltip(index)
    local x = 0
    if (index % 2) == 0 then
        x = 30
    end
    local y = 220

    local stats = GetStats()
    local stat = stats[index]
    local text = __HeroStats[__SelectedHero][stat]["Percentile"]["Text"]

    SetPosition('MeterTooltipBackground', x, y)
    SetPosition('MeterTooltipText', x, y)
    SetTitle('MeterTooltipText', text)
    --ShowGroup("Tooltip")
end

function HideTooltip()
    HideGroup("Tooltip")
end

function GetAPIURL()
    return __APIURL
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end