

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "DC-17m Blaster Rifle"			
	SWEP.Author				= "Ce1azz"
	SWEP.ViewModelFOV      	= 50
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.WepSelectIcon = surface.GetTextureID("HUD/killicons/DC17M_BR")
	
	killicon.Add( "weapon_752_dc17m_br", "HUD/killicons/DC17M_BR", Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType				= "ar2"
SWEP.Base					= "weapon_swsft_base"

SWEP.Category				= "Star Wars"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_DC17M_BR.mdl"
SWEP.WorldModel				= "models/weapons/w_DC17M_BR.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

local FireSound 			= Sound ("weapons/DC17M_BR_fire.wav");
local ReloadSound			= Sound ("weapons/DC17M_BR_reload.wav");

SWEP.Primary.Recoil			= 0.5
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 60
SWEP.Primary.Delay			= 0.13125
SWEP.Primary.DefaultClip	= 180
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9х19 mm Parabellum"
SWEP.Primary.Tracer 		= "effect_sw_laser_blue"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector (-4.7, -6, 0.3)

function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( FireSound )
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-1,1) * self.Primary.Recoil, math.Rand(-1,1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 1								// Show a tracer on every x bullets 
	bullet.TracerName 	= self.Primary.Tracer
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end

function SWEP:Think()	
	local ClipPercentage = ((100/self.Primary.ClipSize)*self.Weapon:Clip1());
	
	if (ClipPercentage < 1) then
		self.Owner:GetViewModel():SetSkin( 10 )
		return
	end
	if (ClipPercentage < 11) then
		self.Owner:GetViewModel():SetSkin( 9 )
		return
	end
	if (ClipPercentage < 21) then
		self.Owner:GetViewModel():SetSkin( 8 )
		return
	end
	if (ClipPercentage < 31) then
		self.Owner:GetViewModel():SetSkin( 7 )
		return
	end
	if (ClipPercentage < 41) then
		self.Owner:GetViewModel():SetSkin( 6 )
		return
	end
	if (ClipPercentage < 51) then
		self.Owner:GetViewModel():SetSkin( 5 )
		return
	end
	if (ClipPercentage < 61) then
		self.Owner:GetViewModel():SetSkin( 4 )
		return
	end
	if (ClipPercentage < 71) then
		self.Owner:GetViewModel():SetSkin( 3 )
		return
	end
	if (ClipPercentage < 81) then
		self.Owner:GetViewModel():SetSkin( 2 )
		return
	end
	if (ClipPercentage < 91) then
		self.Owner:GetViewModel():SetSkin( 1 )
		return
	end
	if (ClipPercentage < 101) then
		self.Owner:GetViewModel():SetSkin( 0 )
	end
end
