--[[--------------------------------------------------------------------
	!ClassColors
	Change class colors without breaking the Blizzard UI.
	Copyright 2009-2018 Phanx <addons@phanx.net>. All rights reserved.
	https://github.com/phanx-wow/ClassColors
	https://www.curseforge.com/wow/addons/classcolors
	https://www.wowinterface.com/downloads/info12513-ClassColors.html
----------------------------------------------------------------------]]
-- ref: https://www.townlong-yak.com/globe/wut/#q:RAID_CLASS_COLORS

local _, ns = ...

local strfind, format, gsub, strmatch, strsub = string.find, string.format, string.gsub, string.match, string.sub
local pairs, type = pairs, type

------------------------------------------------------------------------

local addonFuncs = {}

local blizzHexColors = {}
for class, color in pairs(RAID_CLASS_COLORS) do
	blizzHexColors[color.colorStr] = class
end

------------------------------------------------------------------------
-- Blizzard_Calendar/Blizzard_Calendar.lua
-- 7.3.0.24920
-- 3320, 4084

addonFuncs["Blizzard_Calendar"] = function()
	local _G = _G
	local CalendarViewEventInviteListScrollFrame, CalendarCreateEventInviteListScrollFrame = CalendarViewEventInviteListScrollFrame, CalendarCreateEventInviteListScrollFrame
	local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
	local CalendarEventGetNumInvites, CalendarEventGetInvite = CalendarEventGetNumInvites, CalendarEventGetInvite

	hooksecurefunc("CalendarViewEventInviteListScrollFrame_Update", function() -- 3385
		local _, namesReady = CalendarEventGetNumInvites()
		if not namesReady then return end

		local buttons = CalendarViewEventInviteListScrollFrame.buttons
		local offset = HybridScrollFrame_GetOffset(CalendarViewEventInviteListScrollFrame)
		for i = 1, #buttons do
			local _, _, _, class = CalendarEventGetInvite(i + offset)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				local buttonName = buttons[i]:GetName()
				_G[buttonName.."Name"]:SetTextColor(color.r, color.g, color.b)
				_G[buttonName.."Class"]:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)

	hooksecurefunc("CalendarCreateEventInviteListScrollFrame_Update", function() -- 4149
		local _, namesReady = CalendarEventGetNumInvites()
		if not namesReady then return end

		local buttons = CalendarCreateEventInviteListScrollFrame.buttons
		local offset = HybridScrollFrame_GetOffset(CalendarCreateEventInviteListScrollFrame)
		for i = 1, #buttons do
			local _, _, _, class = CalendarEventGetInvite(i + offset)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				local buttonName = buttons[i]:GetName()
				_G[buttonName.."Name"]:SetTextColor(color.r, color.g, color.b)
				_G[buttonName.."Class"]:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end

------------------------------------------------------------------------
-- Blizzard_ChallengesUI/Blizzard_ChallengesUI.lua
-- 7.3.0.25021
-- 204, 218, 675
-- Out of Date in Retail 
addonFuncs["Blizzard_ChallengesUI"] = function()
	local function ChallengesGuildBestMixin_SetUp(self, leaderInfo) -- 204
		self.CharacterName:SetFormattedText(leaderInfo.isYou and CHALLENGE_MODE_GUILD_BEST_LINE_YOU or CHALLENGE_MODE_GUILD_BEST_LINE,
			CUSTOM_CLASS_COLORS[leaderInfo.classFileName].colorStr,
			leaderInfo.name)
	end

	local function GuildChallengesGuildBestMixin_OnEnter(self) -- 218
		local leaderInfo = self.leaderInfo

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local name = C_ChallengeMode.GetMapInfo(leaderInfo.mapChallengeModeID)
		GameTooltip:SetText(name, 1, 1, 1)
		GameTooltip:AddLine(CHALLENGE_MODE_POWER_LEVEL:format(leaderInfo.level))
		for i = 1, #leaderInfo.members do
			local classColorStr = CUSTOM_CLASS_COLORS[leaderInfo.members[i].classFileName].colorStr
			GameTooltip:AddLine(CHALLENGE_MODE_GUILD_BEST_LINE:format(classColorStr, leaderInfo.members[i].name))
		end
		GameTooltip:Show()
	end

	hooksecurefunc("ChallengesFrame_Update", function(self)
		if self.leadersAvailable then
			local leaders = C_ChallengeMode.GetGuildLeaders()
			if leaders and #leaders > 0 then
				for i = 1, #leaders do
					local frame = self.GuildBest.GuildBests[i]
					frame:SetScript("OnEnter", GuildChallengesGuildBestMixin_OnEnter)
					ChallengesGuildBestMixin_SetUp(frame, leaders[i])
				end
			end
		end
	end)

	-- ChallengeModeBannerPartyMemberMixin:SetUp(unitToken)
	hooksecurefunc(ChallengeModeCompleteBanner, "PlayBanner", function(self, data) -- 675
		local sortedUnitTokens = self:GetSortedPartyMembers()
		for i = 1, #sortedUnitTokens do
			local unitToken = sortedUnitTokens[i]
			local name = UnitName(unitToken)
			local _, classFileName = UnitClass(unitToken)
			local classColorStr = CUSTOM_CLASS_COLORS[classFileName].colorStr
			self.PartyMembers[i].Name:SetFormattedText("|c%s%s|r", classColorStr, name)
		end
	end)
end

------------------------------------------------------------------------
-- Blizzard_Collections/Classic/Blizzard_HeirloomCollection.lua
-- 7.3.0.25021
-- 746

addonFuncs["Blizzard_Collections"] = function()
	local NO_CLASS_FILTER = 0
	local NO_SPEC_FILTER = 0

	function HeirloomsJournal:UpdateClassFilterDropDownText() -- 746
		local text
		local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters()
		if classFilter == NO_CLASS_FILTER then
			text = ALL_CLASSES
		else
			local classInfo = C_CreatureInfo.GetClassInfo(classFilter)
			if not classInfo then return end;

			local classColorStr = CUSTOM_CLASS_COLORS[classInfo.classFile].colorStr
			if specFilter == NO_SPEC_FILTER then
				text = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classInfo.className)
			else
				local specName = GetSpecializationNameForSpecID(specFilter)
				text = HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT:format(classColorStr, classInfo.className, specName)
			end
		end
		UIDropDownMenu_SetText(self.classDropDown, text)
	end
end

------------------------------------------------------------------------
-- Blizzard_Commentator
-- CommentatorCooldownDisplay.lua
-- 7.3.0.25021
-- 156
-- Blizzard_Commentator/UnitFrame.lua
-- 7.3.0.25021
-- 208
-- Blizzard_CommentatorNamePlate.lua
-- 4.4.0.54339 | 214

addonFuncs["Blizzard_Commentator"] = function()
	-- Blizzard Commentator is not accessible by players anymore, its a specate mode that can only be used by Blizzard usually for tournaments.
		
	-- CommentatorCooldownDisplayFrame no longer in any live client
	if CommentatorCooldownDisplayFrame then
		local hookedCooldownFrames = {}

		local function setCooldownClass(self, class)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if class then
				self.Name:SetVertexColor(color.r, color.g, color.b, 1.0)
			end
		end

		local function postAcquireCooldown(self)
			for frame in next, self.activeObjects do
				if not hookedCooldownFrames[frame] then
					hooksecurefunc(frame, "SetClass", setCooldownClass)
					hookedCooldownFrames[frame] = true
				end
			end
		end
		hooksecurefunc(CommentatorCooldownDisplayFrame.TeamFrame1.playerRowPool, "Acquire", postAcquireCooldown)
		hooksecurefunc(CommentatorCooldownDisplayFrame.TeamFrame2.playerRowPool, "Acquire", postAcquireCooldown)
	end

	-- PvPCommentator no longer in any live client
	if PvPCommentator then 
		local function setUnitFrameClass(self, class)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				self.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
			end
		end

		-- PvPCommentatorMixin:OnLoad()
		for teamIndex, frames in pairs(PvPCommentator.unitFrames) do
			for playerIndex, frame in pairs(frames) do
				hooksecurefunc(frame, "SetClass", setUnitFrameClass)
			end
		end
	end
end

------------------------------------------------------------------------
-- Blizzard_Communities
-- https://github.com/Gethe/wow-ui-source/blame/87c526a3ae979a7f5244d635bd8ae952b4313bd8/Interface/AddOns/Blizzard_Communities/CommunitiesMemberList.lua#L937C3-L937C3

addonFuncs["Blizzard_Communities"] = function()
	local function ScrollElement_ColorPlayerName(frame)
		if not frame.GetMemberInfo then return end
		local memberInfo = frame:GetMemberInfo()
		if memberInfo then
			if memberInfo.classID 
			and memberInfo.presence ~= Enum.ClubMemberPresence.Offline
			then
				local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID)
				local color = (classInfo and CUSTOM_CLASS_COLORS[classInfo.classFile])
				if color then
					frame.NameFrame.Name:SetTextColor(color.r, color.g, color.b)
				end
			end
		end
	end
	-- CommunitiesMemberList.lua
	hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
		local memberFrames = {}
		if self.ListScrollFrame then -- all classic flavors
			memberFrames =  self.ListScrollFrame.buttons
		elseif self.ScrollBox then  -- retail
			memberFrames = self.ScrollBox:GetFrames()
		end
		for _, frame in ipairs(memberFrames) do
			ScrollElement_ColorPlayerName(frame)
		end
	end)
	-- CommuntiesChatFrame.lua (retail/cata)
	if CommunitiesFrame.Chat then
		-- re-implement the called `GetPlayerCommunityLink`, check for color code, and check look up then swap.
		function GetPlayerCommunityLink(playerName, linkDisplayText, clubId, streamId, epoch, position)
			local oldColorStr, text = linkDisplayText:match("\124c(%x%x%x%x%x%x%x%x)(.+)\124r")
			if oldColorStr and text then
				local classFile = blizzHexColors[oldColorStr]
				local newColor = classFile and CUSTOM_CLASS_COLORS[classFile]
				if newColor then
					linkDisplayText = WrapTextInColorCode(text, newColor.colorStr)
				end
			end
			-- SanitizeCommunityData
			if type(clubId) == "number" then
				clubId = ("%.f"):format(clubId);
			end
			if type(streamId) == "number" then
				streamId = ("%.f"):format(streamId);
			end
			epoch = ("%.f"):format(epoch);
			position = ("%.f"):format(position);

			return LinkUtil.FormatLink("playerCommunity", linkDisplayText, playerName, clubId, streamId, epoch, position);
		end
	end
	--CommunitiesInvitationFrame.lua (retail/cata)
	if CommunitiesFrame.InvitationFrame then
		hooksecurefunc(CommunitiesFrame.InvitationFrame, "DisplayInvitation", 
			function(self, invitationInfo)
				if not (invitationInfo 
					and invitationInfo.club.clubType == Enum.ClubType.Character)
				then return end;

				local inviter = invitationInfo.inviter
				local classID = inviter and inviter.classID
				local classInfo = classID and C_CreatureInfo.GetClassInfo(classID)
				if classInfo then
					local color = CUSTOM_CLASS_COLORS[classInfo.classFile]
					local name = inviter.name or ""
					if color then
						local linkText = GetPlayerLink(
							name,
							("[%s]"):format(WrapTextInColorCode(name, color.colorStr))
						);

						self.InvitationText:SetText(COMMUNITY_INVITATION_FRAME_INVITATION_TEXT:format(linkText));
					end
				end
			end
		);
	end
	-- To color the Tooltip on Community/Guild Cards in the club finder.
	-- ClubFinderGuildCardMixin_OnEnter -> CommunitiesUtil.AddLookingForLines -> CommunitiesUtil.GetRoleSpecClassLine;
	-- ClubFinderApplicantEntryMixin:OnEnter -> GetRoleSpecClassLine
	if CommunitiesUtil.GetRoleSpecClassLine then -- (retail only)
		function CommunitiesUtil.GetRoleSpecClassLine(classID, specID)
			local classInfo = C_CreatureInfo.GetClassInfo(classID);
			local color = CUSTOM_CLASS_COLORS[classInfo.classFile];
			
			local _, specName, _, _, role = GetSpecializationInfoForSpecID(specID);
			local texture;
			if (role == "TANK") then
				texture = CreateAtlasMarkup("roleicon-tiny-tank");
			elseif (role == "DAMAGER") then
				texture = CreateAtlasMarkup("roleicon-tiny-dps");
			elseif (role == "HEALER") then
				texture = CreateAtlasMarkup("roleicon-tiny-healer");
			end
		
			return color:WrapTextInColorCode(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC_WITH_ROLE:format(texture, specName, classInfo.className));
		end
	end
	-- todo: 
	-- CommunitiesTicketManagerDialog.InviteManager.ScrollBox elements
	-- CommunitiesFrame.ApplicantList.ScrollBox elements


	
end
------------------------------------------------------------------------
-- Blizzard_GuildUI/Blizzard_GuildRoster.lua
-- 7.3.0.25021
-- 120

addonFuncs["Blizzard_GuildUI"] = function() -- 120
	hooksecurefunc("GuildRosterButton_SetStringText", function(buttonString, text, isOnline, class)
		local color = isOnline and class and CUSTOM_CLASS_COLORS[class]
		if color then
			buttonString:SetTextColor(color.r, color.g, color.b)
		end
	end)
end

------------------------------------------------------------------------
-- Blizzard_InspectUI/InspectPaperDollFrame.lua
-- 7.3.0.25021
-- 34

addonFuncs["Blizzard_InspectUI"] = function()
	hooksecurefunc("InspectPaperDollFrame_SetLevel", function() -- 34
		local unit = InspectFrame.unit
		if not unit then return end

		local className, class = UnitClass(unit)
		local color = class and CUSTOM_CLASS_COLORS[class]
		if not color then return end

		local spec, specName = GetInspectSpecialization(unit)
		if spec then
			spec, specName = GetSpecializationInfoByID(spec)
		end

		local level, effectiveLevel = UnitLevel(unit), UnitEffectiveLevel(unit)
		if level == -1 or effectiveLevel == -1 then
			level = "??"
		elseif effectiveLevel ~= 1 then
			level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level)
		end

		if specName and specName ~= "" then
			InspectLevelText:SetFormattedText(PLAYER_LEVEL, level, color.colorStr, specName, className)
		else
			InspectLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, level, color.colorStr, className)
		end
	end)
end

------------------------------------------------------------------------
-- Blizzard_RaidUI/Blizzard_RaidUI.lua
-- 7.3.0.25021
-- 374, 551, 736, 1103

addonFuncs["Blizzard_RaidUI"] = function()
	local _G = _G
	local min = math.min
	local GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitCanCooperate, UnitClass = GetNumGroupMembers, GetRaidRosterInfo, IsInRaid, UnitCanCooperate, UnitClass
	local MAX_RAID_MEMBERS, MEMBERS_PER_RAID_GROUP = MAX_RAID_MEMBERS, MEMBERS_PER_RAID_GROUP

	hooksecurefunc("RaidGroupFrame_Update", function() -- 371
		local isRaid = IsInRaid()
		if not isRaid then return end
		for i = 1, min(GetNumGroupMembers(), MAX_RAID_MEMBERS) do
			local name, _, subgroup, _, _, class, _, online, dead = GetRaidRosterInfo(i)
			local color = online and not dead and _G["RaidGroup"..subgroup].nextIndex <= MEMBERS_PER_RAID_GROUP and class and CUSTOM_CLASS_COLORS[class]
			if color then
				local button = _G["RaidGroupButton"..i]
				-- in classic, class is a button not a fontstring
				if button.subframes.class:GetObjectType() == "Button" then
					button.subframes.class.text:SetTextColor(color.r, color.g, color.b)
				else
					button.subframes.class:SetTextColor(color.r, color.g, color.b)
				end	
				button.subframes.name:SetTextColor(color.r, color.g, color.b)
				button.subframes.level:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)

	hooksecurefunc("RaidGroupFrame_UpdateHealth", function(i) -- 548
		local _, _, _, _, _, class, _, online, dead = GetRaidRosterInfo(i)
		local color = online and not dead and class and CUSTOM_CLASS_COLORS[class]
		if color then
			local r, g, b = color.r, color.g, color.b
			_G["RaidGroupButton"..i.."Name"]:SetTextColor(r, g, b)
			_G["RaidGroupButton"..i.."Level"]:SetTextColor(r, g, b)
			local buttonClass = _G["RaidGroupButton"..i.."Class"]
			if buttonClass:GetObjectType() == "Button" then
				-- classic support
				buttonClass.text:SetTextColor(r, g, b)
			else
				buttonClass:SetTextColor(r, g, b)
			end
		end
	end)

	hooksecurefunc("RaidPullout_UpdateTarget", function(frame, button, unit, which) -- 760
		if _G[frame]["show"..which] and UnitCanCooperate("player", unit) then
			local _, class = UnitClass(unit)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				_G[button..which.."Name"]:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)

	local petowners = {}
	for i = 1, 40 do
		petowners["raidpet"..i] = "raid"..i
	end
	hooksecurefunc("RaidPulloutButton_UpdateDead", function(button, dead, class) -- 1100
		local color = not dead and class and CUSTOM_CLASS_COLORS[class]
		if color then
			if class == "PETS" then
				class, class = UnitClass(petowners[button.unit])
			end
			button.nameLabel:SetVertexColor(color.r, color.g, color.b)
		end
	end)
end

------------------------------------------------------------------------
-- Blizzard_StoreUISecure.lua

-- RAID_CLASS_COLORS is referenced several times in here, but it is
-- forbidden to addons, so there's nothing we can do about it.

------------------------------------------------------------------------
-- Blizzard_TradeSkillUI/Blizzard_TradeSkillDetails.lua
-- 7.3.0.25021
-- 469, 470

addonFuncs["Blizzard_TradeSkillUI"] = function()
	-- not present in classic atm
	if not (TradeSkillFrame.DetailsFrame
		and TradeSkillFrame.DetailsFrame.GuildFrame) 
	then return end;
	-- TradeSkillGuildListingMixin:Refresh()
	
	hooksecurefunc(TradeSkillFrame.DetailsFrame.GuildFrame, "Refresh", function(self) -- 470, 471
		if self.waitingOnData then return end

		local _, _, numMembers = GetGuildRecipeInfoPostQuery()
		local offset = FauxScrollFrame_GetOffset(self.Container.ScrollFrame)
		for i, craftersButton in ipairs(self.Container.ScrollFrame.buttons) do
			local dataIndex = offset + i
			if dataIndex > numMembers then
				break
			end

			local _, _, class, online = GetGuildRecipeMember(i + offset)
			local color = online and class and CUSTOM_CLASS_COLORS[class]
			if color then
				craftersButton.Text:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end

------------------------------------------------------------------------
-- FrameXML/ChatFrame.lua
-- 7.3.0.25021
-- 2962, 3289

local function shouldColorChatByClass(info)
	-- 0: always, 1: never, 2: respect info.colorNameByClass
	local override = GetCVar("chatClassColorOverride")
	if override == '0' then 
		return true
	elseif override == "1" then
		return false
	else
		return info and info.colorNameByClass
	end
end
function GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	if not arg2 then
		return arg2
	end

	local chatType = strsub(event, 10)
	if strsub(chatType, 1, 7) == "WHISPER" then
		chatType = "WHISPER"
	elseif strsub(chatType, 1, 7) == "CHANNEL" then
		chatType = "CHANNEL"..arg8
	end

	if chatType == "GUILD" then
		arg2 = Ambiguate(arg2, "guild")
	else
		arg2 = Ambiguate(arg2, "none")
	end

	local info = ChatTypeInfo[chatType]
	if  (arg12 and arg12 ~= "" and arg12 ~= 0) 
		and shouldColorChatByClass(info) 
	then
		local _, class = GetPlayerInfoByGUID(arg12)
		local color = class and CUSTOM_CLASS_COLORS[class]
		if color then
			return format("|c%s%s|r", color.colorStr, arg2)
		end
	end

	return arg2
end

do
	local AddMessage = {}

	local function FixClassColors(frame, message, ...) -- 3174
		if type(message) == "string" and strfind(message, "|cff") then -- type check required for shitty addons that pass nil or non-string values
			for hex, class in pairs(blizzHexColors) do
				local color = CUSTOM_CLASS_COLORS[class]
				message = color and gsub(message, hex, color.colorStr) or message -- color check required for Warmup, maybe others
			end
		end
		return AddMessage[frame](frame, message, ...)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		AddMessage[frame] = frame.AddMessage
		frame.AddMessage = FixClassColors
	end
end

------------------------------------------------------------------------
-- FrameXML/CompactUnitFrame.lua
-- 7.3.0.25021
-- 374

do
	local UnitClass, UnitIsConnected, UnitIsPlayer
	    = UnitClass, UnitIsConnected, UnitIsPlayer

	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame) -- 371
		local opts = frame.optionTable
		if opts.healthBarColorOverride or not opts.useClassColors
		or not (opts.allowClassColorsForNPCs or UnitIsPlayer(frame.unit))
		or not UnitIsConnected(frame.unit) then
			return
		end

		local _, class = UnitClass(frame.unit)
		local color = class and CUSTOM_CLASS_COLORS[class]
		if not color then return end

		frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
		if frame.optionTable.colorHealthWithExtendedColors then
			frame.selectionHighlight:SetVertexColor(color.r, color.g, color.b)
		end
	end)
end

------------------------------------------------------------------------
-- FrameXML/FriendsFrame_Shared.lua
-- 4.4.0.54339 | 661
-- SharedXML/FriendsFrame.lua
-- 10.2.7.54295 | 817

if WhoList_InitButton then -- retail method
	hooksecurefunc("WhoList_InitButton", function(button, elementData) -- 817
		local info = elementData.info
		local color = info and info.filename and CUSTOM_CLASS_COLORS[info.filename]
		if color then
			button.Class:SetTextColor(color.r, color.g, color.b)
		end
	end)
else -- classic clients
	hooksecurefunc("WhoList_Update", function() -- 661
		local offset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
		for i = 1, WHOS_TO_DISPLAY do
			local info = C_FriendList.GetWhoInfo(i + offset)
			local color = class and CUSTOM_CLASS_COLORS[info.filename]
			if color then
				_G["WhoFrameButton"..i.."Class"]:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end


------------------------------------------------------------------------
-- FrameXML/LFDFrame.lua
-- 1.15.2.54067 | 491
-- 4.4.0 | 491 (under `/Addons/Blizzard_GroupFinder/`)

hooksecurefunc("LFDQueueFrameRandomCooldownFrame_Update", function()
	for i = 1, GetNumSubgroupMembers() do
		local _, class = UnitClass("party"..i)
		local color = class and CUSTOM_CLASS_COLORS[class]
		if color then
			local name, server = UnitName("party"..i) -- skip call to GetUnitName wrapper func
			if server and server ~= "" then
				_G["LFDQueueFrameCooldownFrameName"..i]:SetFormattedText("|c%s%s-%s|r", color.colorStr, name, server)
			else
				_G["LFDQueueFrameCooldownFrameName"..i]:SetFormattedText("|c%s%s|r", color.colorStr, name)
			end
		end
	end
end)

------------------------------------------------------------------------
-- FrameXML/LFGFrame.lua
-- 4.4.0.54339 | 1966

hooksecurefunc("LFGCooldownCover_Update", function(self)
	local nextIndex, numPlayers, prefix = 1
	if IsInRaid() then
		numPlayers = GetNumGroupMembers()
		prefix = "raid"
	else
		numPlayers = GetNumSubgroupMembers()
		prefix = "party"
	end

	for i = 1, numPlayers do
		if nextIndex > #self.Names then
			break
		end

		local unit = prefix..i
		if self.showAll or (self.showCooldown and UnitHasLFGRandomCooldown(unit)) or UnitHasLFGDeserter(unit) then
			local _, class = UnitName(unit)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				local name, server = UnitName(unit) -- skip call to GetUnitName wrapper func
				if server and server ~= "" then
					self.Names[nextIndex]:SetFormattedText("|c%s%s-%s|r", color.colorStr, name, server)
				else
					self.Names[nextIndex]:SetFormattedText("|c%s%s|r", color.colorStr, name)
				end
			end
			nextIndex = nextIndex + 1
		end
	end
end)

------------------------------------------------------------------------
-- FrameXML/LFGList.lua
-- 7.3.0.25021
-- 1479, 1558, 3170

local grayedOutStatus = {
	failed = true,
	cancelled = true,
	declined = true,
	declined_full = true,
	declined_delisted = true,
	invitedeclined = true,
	timedout = true,
}

hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, appID, memberIdx, status, pendingStatus)
	if not pendingStatus and grayedOutStatus[status] then
		-- grayedOut
		return
	end

	local name, class = C_LFGList.GetApplicantMemberInfo(appID, memberIdx)
	local color = name and class and CUSTOM_CLASS_COLORS[class]
	if color then
		member.Name:SetTextColor(color.r, color.g, color.b)
	end
end)

hooksecurefunc("LFGListApplicantMember_OnEnter", function(self) -- 1551
	local applicantID = self:GetParent().applicantID
	local memberIdx = self.memberIdx
	local name, class = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
	local color = name and class and CUSTOM_CLASS_COLORS[class]
	if color then
		GameTooltipTextLeft1:SetTextColor(color.r, color.g, color.b)
	end
end)

local LFG_LIST_TOOLTIP_MEMBERS_SIMPLE = gsub(LFG_LIST_TOOLTIP_MEMBERS_SIMPLE, "%%d", "%%d+")

hooksecurefunc("LFGListSearchEntry_OnEnter", function(self) -- 3128
	local resultID = self.resultID
	local _, activityID, _, _, _, _, _, _, _, _, _, _, numMembers = C_LFGList.GetSearchResultInfo(resultID)
	local _, _, _, _, _, _, _, _, displayType = C_LFGList.GetActivityInfo(activityID)
	if displayType ~= LE_LFG_LIST_DISPLAY_TYPE_CLASS_ENUMERATE then return end
	local start
	for i = 4, GameTooltip:NumLines() do
		if strfind(_G["GameTooltipTextLeft"..i]:GetText(), LFG_LIST_TOOLTIP_MEMBERS_SIMPLE) then
			start = i
			break
		end
	end
	if start then
		for i = 1, numMembers do
			local _, class = C_LFGList.GetSearchResultMemberInfo(resultID, i)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				_G["GameTooltipTextLeft"..(start+i)]:SetTextColor(color.r, color.g, color.b)
			end
		end
	end
end)

------------------------------------------------------------------------
-- FrameXML/LFRFrame.lua
-- 7.3.0.25021
-- 505
if LFRBrowseFrameListButton_SetData then
	hooksecurefunc("LFRBrowseFrameListButton_SetData", function(button, index)
		local _, _, _, _, _, _, _, class = SearchLFGGetResults(index)
		local color = class and CUSTOM_CLASS_COLORS[class]
		if color then
			button.class:SetTextColor(color.r, color.g, color.b)
		end
	end)
else
	-- print(_, ": LFRBrowseFrameListButton_SetData not found")
end

------------------------------------------------------------------------
-- FrameXML/LevelUpDisplay.lua
-- 7.3.0.25021
-- 1359
if BossBanner_ConfigureLootFrame then
	hooksecurefunc("BossBanner_ConfigureLootFrame", function(lootFrame, data)
			local color = CUSTOM_CLASS_COLORS[data.className]
			lootFrame.PlayerName:SetTextColor(color.r, color.g, color.b)
	end)
else
	-- print(_, ": BossBanner_ConfigureLootFrame not found")
end
-- Moved to BossBannerToast.lua

------------------------------------------------------------------------
-- FrameXML/LootFrame.lua
-- 1.15.2 | 610
-- FrameXML/GroupLootFrame.lua
-- 10.2.6 | 696

hooksecurefunc("MasterLooterFrame_UpdatePlayers", function()
	-- TODO: Find a better way of doing this... Blizzard's way is frankly quite awful,
	-- creating multiple new local tables every time the function runs. :(
	for _, child in pairs(MasterLooterFrame) do
		if type(child) == "table"
			and child.id and child.Name
			and child.GetObjectType
			and child:GetObjectType() == "Button"
		then
			local i = child.id
			local _, class
			if IsInRaid() then
				_, class = UnitClass("raid"..i)
			elseif i > 1 then
				_, class = UnitClass("party"..i)
			else
				_, class = UnitClass("player")
			end

			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				child.Name:SetTextColor(color.r, color.g, color.b)
			end
		end
	end
end)

------------------------------------------------------------------------
-- FrameXML/LootHistory.lua
-- 7.3.0.25021
-- 242, 286, 419
if LootHistoryFrame then
	hooksecurefunc("LootHistoryFrame_UpdateItemFrame", function(self, itemFrame) -- 242
		local itemID = itemFrame.itemIdx
		local rollID, _, _, done, winnerID = C_LootHistory.GetItem(itemID)
		local expanded = self.expandedRolls[rollID]
		if done and winnerID and not expanded then
			local _, class = C_LootHistory.GetPlayerInfo(itemID, winnerID)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				itemFrame.WinnerName:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end)

	hooksecurefunc("LootHistoryFrame_UpdatePlayerFrame", function(self, playerFrame) -- 286
		if playerFrame.playerIdx then
			local name, class = C_LootHistory.GetPlayerInfo(playerFrame.itemIdx, playerFrame.playerIdx)
			local color = name and class and CUSTOM_CLASS_COLORS[class]
			if color then
				playerFrame.PlayerName:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end)

	function LootHistoryDropDown_Initialize(self) -- 419
		local info = UIDropDownMenu_CreateInfo()
		info.text = MASTER_LOOTER
		info.fontObject = GameFontNormalLeft
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)

		local name, class = C_LootHistory.GetPlayerInfo(self.itemIdx, self.playerIdx)
		local color = CUSTOM_CLASS_COLORS[class]

		info = UIDropDownMenu_CreateInfo()
		info.text = format(MASTER_LOOTER_GIVE_TO, format("|c%s%s|r", color.colorStr, name))
		info.func = LootHistoryDropDown_OnClick
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)
	end
else
	-- retail moved to GroupLootHistoryFrame and a new system of tracking loot rolls
	-- support required.
end
------------------------------------------------------------------------
-- FrameXML/PaperDollFrame.lua
-- 7.3.0.25021
-- 418
hooksecurefunc("PaperDollFrame_SetLevel", function() -- 418
	local className, class = UnitClass("player")
	local color = CUSTOM_CLASS_COLORS[class].colorStr
	local specName;
	-- classic era doesnt add the spec name or color in the format string
	-- (though it is available to deduce)
	-- see https://wago.tools/db2/GlobalStrings?build=1.15.2.54262&filter[BaseTag]=PLAYER_LEVEL
	if not strfind(PLAYER_LEVEL, "\124c") then return end
	if GetSpecialization and GetSpecializationInfo then
		local specID = GetSpecialization()
		if specID then
			specID, specName = GetSpecializationInfo(specID)
		end
	elseif GetPrimaryTalentTree then
		-- https://warcraft.wiki.gg/wiki/API_GetPrimaryTalentTree 
		-- added in cata classic 
		local specID = GetPrimaryTalentTree()
		if specID then
			specName = select(2, GetTalentTabInfo(specID))
		end
	end

	local level = UnitLevel("player")
	local effectiveLevel = UnitEffectiveLevel("player")
	if effectiveLevel ~= level then
		level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level)
	end

	if specName and specName ~= "" then
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL, level, color, specName, className)
	else
		CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, level, color, className)
	end
end)

------------------------------------------------------------------------
-- FrameXML/RaidFinder.lua
-- 7.3.0.25021
-- 488
if RaidFinderQueueFrameCooldownFrame_Update then
	hooksecurefunc("RaidFinderQueueFrameCooldownFrame_Update", function() -- 488
		local prefix, members
		if IsInRaid() then
			prefix, members = "raid", GetNumGroupMembers()
		else
			prefix, members = "party", GetNumSubgroupMembers()
		end

		local cooldowns = 0
		for i = 1, members do
			local unit = prefix .. i
			if UnitHasLFGDeserter(unit) and not UnitIsUnit(unit, "player") then
				cooldowns = cooldowns + 1
				if cooldowns <= MAX_RAID_FINDER_COOLDOWN_NAMES then
					local _, class = UnitClass(unit)
					local color = class and CUSTOM_CLASS_COLORS[class]
					if color then
						_G["RaidFinderQueueFrameCooldownFrameName" .. cooldowns]:SetFormattedText("|c%s%s|r", color.colorStr, UnitName(unit))
					end
				end
			end
		end
	end)
else
	-- print(_, ": RaidFinderQueueFrameCooldownFrame_Update not found")
end

------------------------------------------------------------------------
-- FrameXML/RaidWarning.lua
-- 7.3.0.25021
-- 130

do
	local AddMessage = RaidNotice_AddMessage
	RaidNotice_AddMessage = function(frame, message, ...) -- 130
		if strfind(message, "|cff") then
			for hex, class in pairs(blizzHexColors) do
				-- nil check required since `blizzHexColors` stores entries for all classes
				-- and `CUSTOM_CLASS_COLORS` only contains entries for those in the game version
				local color = CUSTOM_CLASS_COLORS[class]
				if color then 
					message = gsub(message, hex, color.colorStr)
				end
			end
		end
		return AddMessage(frame, message, ...)
	end
end
------------------------------------------------------------------------
-- FrameXML/ChatConfigFrame.xml
-- 4.4.0.54339
-- 677, 701
if ChatConfigChannelSettingsClassColorLegend
	and ChatConfigChatSettingsClassColorLegend
then -- only in classic clients
	local ClassColorLegend_OnShow = function(self)
		if not self.classStrings then return end;
		for key, classString in ipairs(self.classStrings) do
			---@cast classString FontString
			local classFile = CLASS_SORT_ORDER[key]
			local color = classFile and CUSTOM_CLASS_COLORS[classFile]
			if color then
				classString:SetFormattedText("\124c%s%s\124r", 
					color.colorStr, LOCALIZED_CLASS_NAMES_MALE[classFile]
				);
			end
		end
	end

	ChatConfigChannelSettingsClassColorLegend:HookScript("OnShow", 
		ClassColorLegend_OnShow
	);
	ChatConfigChatSettingsClassColorLegend:HookScript("OnShow",
		ClassColorLegend_OnShow
	);
end 
------------------------------------------------------------------------
--FrameXML/CommunitiesUtil.lua
-- 1.15.2 | 4
-- 4.4.0.54339 | 4
function CommunitiesUtil.GetMemberRBG(memberInfo)
	if memberInfo.classID then
		local info = C_CreatureInfo.GetClassInfo(memberInfo.classID);
		if info then
			local color = CUSTOM_CLASS_COLORS[info.classFile];
			return color.r, color.g, color.b;
		end
	else return BATTLENET_FONT_COLOR:GetRGB() end;
end
------------------------------------------------------------------------
-- Blizzard_CharacterFrame/Cata/PaperDollFrame.lua
-- 4.4.0.54339 | 533
-- Covered by FrameXML/PaperDollFrame.lua section

------------------------------------------------------------------------
-- Blizzard_ChatFrameBase/Classic/ChatFrame.lua
-- 4.4.0.54339 | 3224, 3285 
-- Covered by FrameXML/ChatFrame.lua section

------------------------------------------------------------------------
-- GetClassColor Wrappers
-- 10.2.6.53989 
-- RosterButton.lua @ 265
local function RosterButtons_SetNameColor(buttons)
	for _, button in ipairs(buttons) do
		if button.playerLocation then
			local _, class = C_PlayerInfo.GetClass(button.playerLocation)
			local color = class and CUSTOM_CLASS_COLORS[class]
			if color then
				button.Name:SetTextColor(color.r, color.g, color.b)
			end
		end
	end
end
if ChannelFrame.ChannelRoster.ScrollBox then
	hooksecurefunc(ChannelFrame.ChannelRoster.ScrollBox, "Update", function(self)
		RosterButtons_SetNameColor(self:GetFrames())
	end)
elseif ChannelFrame.ChannelRoster.ScrollFrame then
	-- The ChannelRoster Update is only called when swapping between channels
	hooksecurefunc(ChannelFrame.ChannelRoster, "Update", function(self)
		RosterButtons_SetNameColor(self.ScrollFrame.buttons)
	end)
	-- note the lowercase `update` method
	-- The ScrollFrame update is only called when actually scrolled.
	hooksecurefunc(ChannelFrame.ChannelRoster.ScrollFrame, "update", function(self)
		RosterButtons_SetNameColor(self.buttons)
	end)

end 

-- Blizzard_CommentatorUnitFrame.lua @ 283 (not used)

-- ClubFinder.lua
-- 4.4.0.54339 @ 688 | 10.2.6.53989 @ 688

-- ClubFinderApplicantList.lua
-- 4.4.0.54339 @ 80 | 10.2.6.53989 @ 80

-- CommunitiesUtil.lua
-- 4.4.0.54339 @ 320 | 10.2.6.53989 @ 320

-- ItemRef.lua 
-- 10.2.6.53989 @ 607, 672

-- StaticPopup.lua @ 1567, 3043
-- GROUP_INVITE_CONFIRMATION | DUEL_TO_THE_DEATH_REQUESTED
hooksecurefunc(StaticPopupDialogs.GROUP_INVITE_CONFIRMATION, "OnHyperlinkEnter",
	function(self)
		if not self.data then return end
		local _, _, guid, roles, _, level = GetInviteConfirmationInfo(self.data);
		local _, classFile, _, _, _, name, _ = GetPlayerInfoByGUID(guid or "");
		local color = classFile and CUSTOM_CLASS_COLORS[classFile];
		if name and color then			
			GameTooltipTextLeft1:SetText(WrapTextInColorCode(name, color.colorStr));
		end
	end
);
if StaticPopupDialogs.DUEL_TO_THE_DEATH_REQUESTED then
	-- only in classic clients
	hooksecurefunc(StaticPopupDialogs.DUEL_TO_THE_DEATH_REQUESTED, "OnHyperlinkEnter",
		function(self)
			local guid, level = GetDuelerInfo();
			local _, classFile, _, _, _, name, _ = GetPlayerInfoByGUID(guid or "");
			local color = classFile and CUSTOM_CLASS_COLORS[classFile];
			if name and color then			
				GameTooltipTextLeft1:SetText(WrapTextInColorCode(name, color.colorStr));
			end
		end
	);
end


-- UnitPositionFrameTemplates.lua
-- 1.15.2.54262 @ 225 |4.4.0.54339 @ 235 | 10.2.6.53989 @ 231
-- in function UnitPositionFrameMixin:GetUnitColor
-- used by UnitPositionFrameTemplate inheriting frames
-- such as any GroupMembersPinTemplate and any inheriting frames
-- see GroupMembersDataProviderMixin
-- This affect class colors in: Blizzard_WorldMap.lua, Blizzard_BattlefieldMap.lua

-- UnitPopupShared.lua
-- 1.15.2.54262 @ 134 | 4.4.0.54339 @ 134 | 10.2.6.53989 @ 134
-- This one is the most likely to taint.
-- in function UnitPopupManager:AddDropDownTitle()

------------------------------------------------------------------------
-- PlayerUtil.GetClassColor Wrapper
-- Calls C_ClassColor.GetClassColor
------------------------------------------------------------------------


local numAddons = 0

for addon, func in pairs(addonFuncs) do
	if C_AddOns.IsAddOnLoaded(addon) then
		addonFuncs[addon] = nil
		func()
	else
		numAddons = numAddons + 1
	end
end

if numAddons > 0 then
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(self, event, addon)
		local func = addonFuncs[addon]
		if func then
			addonFuncs[addon] = nil
			numAddons = numAddons - 1
			func()
		end
		if numAddons == 0 then
			self:UnregisterEvent("ADDON_LOADED")
			self:SetScript("OnEvent", nil)
		end
	end)
end

ns.alreadyLoaded = true
