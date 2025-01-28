-- initialization
	regeff_list={}
	
-- functions
Card.RegisterEffect=(function()
	local oldf=Card.RegisterEffect
	return function(c,e,forced,...)
		local reg_e=oldf(c,e,forced)
		if not reg_e or reg_e<=0 then return reg_e end
		local resetflag,resetcount=e:GetReset()
		for _,val in ipairs{...} do
			local code=regeff_list[val]
			if code then
				local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
				if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
				e2:SetCode(code)
				e2:SetLabelObject(e)
				e2:SetLabel(c:GetOriginalCode())
				if resetflag and resetcount then
					e2:SetReset(resetflag,resetcount)
				elseif resetflag then
					e2:SetReset(resetflag)
				end
				c:RegisterEffect(e2)
			end
		end
		return reg_e
	end
end)()

local function CheckEffectUniqueCheck(c,tp,code)
	if not (aux.FaceupFilter(Card.IsCode,code) and c:IsHasEffect(EFFECT_UNIQUE_CHECK)) then 
		return false
	end
	return true
end
function aux.CheckEffectUniqueCheck(c,tp,code)
	if not (aux.FaceupFilter(Card.IsCode,code) and c:IsHasEffect(EFFECT_UNIQUE_CHECK)) then 
		return false
	end
	return true
end
local function AdjustOp(self,opp,limit,code,location)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local phase=Duel.GetCurrentPhase()
		local rm=Group.CreateGroup()
		if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
		if self then
			local g=Duel.GetMatchingGroup(CheckEffectUniqueCheck,tp,location,0,nil,tp,code)
			local rg=Group.CreateGroup()
			if #g>0 then
				g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,code),tp,location,0,nil)
				local ct=#g-limit
				if #g>limit then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
					rg=g:Select(1-tp,ct,ct,nil):GetFirst()
					Duel.HintSelection(rg,true)
				end
			end
			rm:Merge(rg)
		end
		if opp then
			local g=Duel.GetMatchingGroup(CheckEffectUniqueCheck,tp,0,location,nil,tp,code)
			local rg=Group.CreateGroup()
			if #g>0 then
				g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,code),tp,0,location,nil)
				local ct=#g-limit
				if #g>limit then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
					rg=g:Select(1-tp,ct,ct,nil):GetFirst()
					Duel.HintSelection(rg,true)
				end
			end
			rm:Merge(rg)
		end
		if #rm>0 then			
			Duel.SendtoGrave(rm,REASON_RULE)
			Duel.Readjust()
		end
	end
end
local function SummonLimit(limit,code,location)
	return function(e,c,sump,sumtype,sumpos,targetp)
		if not c:IsCode(code) then return false end
		local g=Duel.GetMatchingGroupCount(CheckEffectUniqueCheck,targetp or sump,location,0,1,targetp or sump,code) 
		if g>0 then
			local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,code),targetp or sump,location,0,1)
			return g>limit-1
		end
	end
end
-- Sets the max number of copies the card(code) can have on the field
function Card.SetLimitOnField(c,limit,code,location,self,opp)
	if not limit then limit=1 end
	if not location then location=LOCATION_ONFIELD end	
	if not code then code=c:GetCode() end
	if not self then self=true end
	if not opp then opp=false end
	--Adjust
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(location)
	e1:SetOperation(AdjustOp(self,opp,limit,code,location))
	c:RegisterEffect(e1,false,CUSTOM_REGISTER_LIMIT)
	c:RegisterFlagEffect(CUSTOM_REGISTER_LIMIT,RESET_DISABLE,0,1,3)
	--Cannot Normal/Flip/Special Summon from location
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(SummonLimit(limit,code,location))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
end
function aux.CheckLimitForCard(tp,code)
	return Duel.IsExistingMatchingCard(aux.CheckEffectUniqueCheck,tp,LOCATION_ALL,0,1,nil,tp,code)
end
-- Returns the max number of copies the card can have on the field
function Card.GetMaxLimitForCard(c)
	return c:GetFlagEffectLabel(CUSTOM_REGISTER_LIMIT)
end
-- Returns the max number of copies the card with code can have on the field
function aux.GetMaxLimitForCard(tp,code,location)
	if not location then location=LOCATION_ALL end	
	local c=Duel.GetMatchingGroup(aux.CheckEffectUniqueCheck,tp,location,0,nil,tp,code):GetFirst()
	if c then return c:GetMaxLimitForCard() end
	return 99
end
-- Returns the number of copies the field can have of a specific card
	-- tp 	    = Target Player
	-- code     = current Card ID
	-- onfield  = flag for checking LOCATION_ONFIELD or LOCATION_ALL
	-- location = if flag for onfield is not met, it will check for the location mentioned
function aux.GetLimitForCardCount(tp,code,onfield,location)
	if not location then location=LOCATION_ONFIELD end	
	if onfield then 
		onfield=LOCATION_ONFIELD 
	else
		onfield=LOCATION_ALL 
		location=LOCATION_ALL 
	end	
	local max=aux.GetMaxLimitForCard(tp,code,onfield)
	local chk=Duel.IsExistingMatchingCard(aux.CheckEffectUniqueCheck,tp,location,0,1,nil,tp,code)
	if chk then  
		local ct=max-Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,code),tp,LOCATION_MZONE,0,nil)
		return ct
	end
	return max
end
-- Returns Pendulum Zone Location Count for player(tp)
function aux.GetPendulumZoneCount(tp)
	local ct=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct + 1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct + 1 end
	return ct
end
-- Return summon type of e
function aux.IsSummonType(sumtype)
	return function(e)
		return e:GetHandler():IsSummonType(sumtype)
	end
end
-- Return the Sum of all Pendulum Scales of tp
function aux.GetPendulumScaleSum(tp)
	local val=0
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) then val=val+Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale() end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,1) then val=val+Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale() end
	return val
end
