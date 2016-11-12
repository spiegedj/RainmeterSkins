function Initialize()

  -- Imports
  dofile(SKIN:GetVariable('@')..'Scripts\\JSONParser.lua')
  dofile(SKIN:GetVariable('@')..'Scripts\\Utils.lua')

  -- Measures
  measureHeroStats = SKIN:GetMeasure('MeasureHeroStats')

  -- Globals
  __Stats = {}
  __SelectedHero = ""
  __APIURL = "https://owapi.net/api/v2/u/Pikmet-1746/heroes/%s/competitive"

  SelectHero('tracer')

  -- heroes

  __Heroes = {
      tracer= {
          type = 'offensive'
      },

      reaper= {
          type = 'offensive'
      },

      dva = {
          type = 'tank'
      },

      mercy = {
          type = 'support'
      },

      lucio = {
          type = 'support'
      },

      ana = {
          type = 'support'
      }
  }

  HideGroup('stats')
end

function SelectHero(hero)
    __SelectedHero = hero

    HideGroup('stats')
    SetMeasureURL('MeasureHeroStats', GetAPIURL())
end

function ParseHeroStats()
    local raw = measureHeroStats:GetStringValue()
    if raw == '' then
        return false
    end
	
    __Stats = JSONParse(raw)

    ShowGroup('stats')

    local type = __Heroes[__SelectedHero]["type"]

    SetTitle("MeterStatsHero", __SelectedHero)
    PrintGeneralStats()
    if type == 'offensive' then
        PrintOffensiveStats()
    elseif type == 'support' then
        PrintSupportStats()
    end
    PrintHeroStats()
end

function PrintGeneralStats()
    local generalStats = __Stats["general_stats"]
    local eliminations = generalStats["eliminations"]
    local gamesPlayed = generalStats["games_played"]

    local eliminationsAvg = round(eliminations/gamesPlayed, 2)
    local winRate = generalStats["win_percentage"]

    SetTitle("MeterWinRate", winRate)
    SetTitle("MeterEliminationsAvg", eliminationsAvg)

end

function PrintOffensiveStats()
    ShowGroup('offensiveStats')
    local generalStats = __Stats["general_stats"]
    local eliminationsPerLife = generalStats["eliminations_per_life"]
    local accuracy = generalStats["weapon_accuracy"]

    SetTitle("MeterTypeStatLabel1", "Eliminations/Life:")
    SetTitle("MeterTypeStat1", eliminationsPerLife)
    SetTitle("MeterTypeStatLabel2", "Accuracy:")
    SetTitle("MeterTypeStat2", accuracy)
end

function PrintSupportStats()
    ShowGroup('supportStats')
    local generalStats = __Stats["general_stats"]
    local gamesPlayed = generalStats["games_played"]
    local healingDone = generalStats["healing_done"]
    local defensiveAssists = generalStats["defensive_assists"]

    SetTitle("MeterTypeStatLabel1", "Healing:")
    SetTitle("MeterTypeStat1", round(healingDone/gamesPlayed, 0))
    SetTitle("MeterTypeStatLabel2", "Def Assists:")
    SetTitle("MeterTypeStat2", round(defensiveAssists/gamesPlayed), 2)
end

function PrintHeroStats()
    local generalStats = __Stats["general_stats"]
    local heroStats = __Stats["hero_stats"]
    local gamesPlayed = generalStats["games_played"]

    if __SelectedHero == 'tracer' then
        stats = GetTracerStats(heroStats, gamesPlayed)
    elseif __SelectedHero == 'mercy' then
        stats = GetMercyStats(heroStats, gamesPlayed)
    elseif __SelectedHero == 'reaper' then
        stats = GetReaperStats(heroStats, gamesPlayed)
    elseif __SelectedHero == 'ana' then
        stats = GetAnaStats(heroStats, gamesPlayed)
    else 
        HideGroup('HeroStats')
        return
    end

    SetTitle("MeterHeroStatLabel1", stats['label1'])
    SetTitle("MeterHeroStat1", stats['stat1'])

    SetTitle("MeterHeroStatLabel2", stats['label2'])
    SetTitle("MeterHeroStat2", stats['stat2'])
end

function GetTracerStats(heroStats, gamesPlayed)
    local bombStuckTotal = heroStats["pulse_bombs_attached"]
    local bombKillTotal = heroStats["pulse_bomb_kills"]
    return {
        label1 = 'Bombs Stuck:',
        stat1 = round(bombStuckTotal/gamesPlayed, 2),
        label2 = 'Bomb Kills:',
        stat2 = round(bombKillTotal/gamesPlayed, 2)
    }
end

function GetMercyStats(heroStats, gamesPlayed)
    local playersResurrectedTotal = heroStats["players_resurrected"]
    return {
        label1 = 'Resurrects:',
        stat1 = round(playersResurrectedTotal/gamesPlayed, 2),
        label2 = '',
        stat2 = ''
    }
end

function GetReaperStats(heroStats, gamesPlayed)
    local dbk = heroStats["death_blossom_kills"]
    local sc = heroStats["souls_consumed"]
    return {
        label1 = 'Blossum Kills:',
        stat1 = round(dbk/gamesPlayed, 2),
        label2 = 'Souls Gained',
        stat2 = round(sc/gamesPlayed, 2)
    }
end

function GetAnaStats(HeroStats, gamesPlayed)
    local nba = HeroStats["nano_boost_assists"]
    local sa = HeroStats["scoped_accuracy"]
    return {
        label1 = 'Nano Boost Assists:',
        stat1 = round(nba/gamesPlayed, 2),
        label2 = 'Scoped Accuracy:',
        stat2 = (sa*100).."%"
    }
end

function GetAPIURL()
    return string.format(__APIURL, __SelectedHero)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end