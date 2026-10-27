do
	local Players = game:GetService("Players");
	local TweenService = game:GetService("TweenService");
	local UIS = game:GetService("UserInputService");
	local RunService = game:GetService("RunService");
	local HttpService = game:GetService("HttpService");
	local RepStorage = game:GetService("ReplicatedStorage");
	local Lighting = game:GetService("Lighting");
	local TeleportSvc = game:GetService("TeleportService");
	local GuiService = game:GetService("GuiService");
	local LP = Players.LocalPlayer;
	local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled ;
	local ENV = (getgenv and getgenv()) or _G ;
	pcall(function()
		if ENV.__MEEN_BB_UNLOAD then
			ENV.__MEEN_BB_UNLOAD();
		end
	end);
	local HUB = {
		Name = "MEEN HUB",
		Version = "V 1.1",
		Logo = "rbxassetid://133012946200414",
		ToggleKey = Enum.KeyCode.RightShift,
		SaveFile = "MeenHub_BladeBall_v110.json"
	};
	local DEFAULTS = {
		AutoParry = false,
		ParryLogic = "Ref",
		RefAccuracy = 100,
		Rearm = false,
		ParryTarget = "Everyone",
		Window = 450,
		PingComp = true,
		PointBlank = 16,
		MinSpeed = 10,
		TargetOnly = true,
		Adaptive = true,
		Preset = "Balanced",
		AutoSpam = false,
		SpamRate = 16,
		SpamRange = 20,
		ClashOnly = false,
		AutoAbility = false,
		AbilityRange = 40,
		BallESP = false,
		FOVOn = false,
		FOV = 90,
		Fullbright = false,
		HitboxESP = false,
		ParryRing = false,
		BallTag = false,
		FPSBoost = false,
		Guard = true,
		AnomalyWatch = true,
		BanWatch = true,
		AutoRejoin = false,
		AntiAFK = true,
		HUD = true,
		ParryFX = true,
		VisualCD = true,
		CDms = 600,
		UIFX = true
	};
	local S = {};
	for k, v in pairs(DEFAULTS) do
		S[k] = v;
	end
	pcall(function()
		if (isfile and isfile(HUB.SaveFile)) then
			local d = HttpService:JSONDecode(readfile(HUB.SaveFile));
			for k, v in pairs(d) do
				if ((DEFAULTS[k] ~= nil) and (type(v) == type(DEFAULTS[k]))) then
					S[k] = v;
				end
			end
		end
	end);
	do
		local R = {
			RefAccuracy = {
				1,
				100
			},
			CDms = {
				200,
				2000
			},
			Window = {
				40,
				600
			},
			PointBlank = {
				0,
				40
			},
			MinSpeed = {
				0,
				120
			},
			SpamRate = {
				5,
				60
			},
			SpamRange = {
				6,
				40
			},
			AbilityRange = {
				10,
				120
			},
			FOV = {
				60,
				120
			}
		};
		for k, r in pairs(R) do
			if ((type(S[k]) ~= "number") or (S[k] ~= S[k])) then
				S[k] = DEFAULTS[k];
			end
			S[k] = math.clamp(S[k], r[1], r[2]);
		end
		if not ({
			Early = 1,
			Balanced = 1,
			Late = 1,
			Custom = 1
		})[S.Preset] then
			S.Preset = "Balanced";
		end
		S.ParryLogic, S.ParryTarget, S.Rearm, S.RefAccuracy, S.Adaptive, S.PingComp = "Ref", "Everyone", false, 100, true, true;
	end
	local C = {
		VIOLET = Color3.fromRGB(139, 92, 246),
		INDIGO = Color3.fromRGB(99, 102, 241),
		CYAN = Color3.fromRGB(56, 189, 248),
		BG = Color3.fromRGB(7, 9, 20),
		PANEL = Color3.fromRGB(13, 13, 30),
		PANEL2 = Color3.fromRGB(22, 20, 48),
		TEXT = Color3.fromRGB(226, 232, 240),
		MUTED = Color3.fromRGB(148, 163, 184),
		OK = Color3.fromRGB(74, 222, 128),
		WARN = Color3.fromRGB(251, 191, 36),
		BAD = Color3.fromRGB(248, 113, 113),
		OFF = Color3.fromRGB(48, 51, 88)
	};
	local WHITE = Color3.new(1, 1, 1);
	local CK = ColorSequenceKeypoint.new;
	local conns, alive = {}, true;
	local function bind(sig, fn)
		local c = sig:Connect(fn);
		table.insert(conns, c);
		return c;
	end
	local Dbg = {
		lines = {}
	};
	local dbgThrottle = {};
	Dbg.log = function(msg, key, gap)
		local now = os.clock();
		if key then
			if (dbgThrottle[key] and ((now - dbgThrottle[key]) < (gap or 2))) then
				return;
			end
			dbgThrottle[key] = now;
		end
		local l = Dbg.lines;
		l[ # l + 1 ] = string.format("[%7.1f] %s", now % 100000, tostring(msg));
		if ( # l > 80) then
			table.remove(l, 1);
		end
	end;
	local function new(cls, props, kids)
		local o = Instance.new(cls);
		for k, v in pairs(props or {}) do
			o[k] = v;
		end
		for _, c in ipairs(kids or {}) do
			c.Parent = o;
		end
		return o;
	end
	local function tw(o, t, p, style, dir)
		local tn = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p);
		tn:Play();
		return tn;
	end
	local function loopTween(o, t, p, delay)
		local tn = TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, - 1, true, delay or 0), p);
		tn:Play();
		return tn;
	end
	local function popIn(o, delay)
		local s = o:FindFirstChild("PopScale") or Instance.new("UIScale") ;
		s.Name = "PopScale";
		s.Scale = 0.93;
		s.Parent = o;
		task.delay(delay or 0, function()
			if s.Parent then
				tw(s, 0.35, {
					Scale = 1
				}, Enum.EasingStyle.Back);
			end
		end);
	end
	local function corner(r)
		return new("UICorner", {
			CornerRadius = UDim.new(0, r)
		});
	end
	local function stroke(col, th, tr)
		return new("UIStroke", {
			Color = col or C.VIOLET,
			Thickness = th or 1,
			Transparency = tr or 0.75,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		});
	end
	local function grad(a, b, rot)
		return new("UIGradient", {
			Rotation = rot or 0,
			Color = ColorSequence.new({
				CK(0, a),
				CK(1, b)
			})
		});
	end
	local function label(parent, props, kids)
		local d = {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = C.TEXT,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = parent
		};
		for k, v in pairs(props) do
			d[k] = v;
		end
		return new("TextLabel", d, kids);
	end
	local function press(b)
		local s = new("UIScale", {
			Parent = b
		});
		b.MouseButton1Down:Connect(function()
			tw(s, 0.08, {
				Scale = 0.95
			});
		end);
		local function up()
			tw(s, 0.25, {
				Scale = 1
			}, Enum.EasingStyle.Back);
		end
		b.MouseButton1Up:Connect(up);
		b.MouseLeave:Connect(up);
	end
	local function button(parent, props, kids)
		local d = {
			AutoButtonColor = false,
			Text = "",
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = C.TEXT,
			Parent = parent
		};
		for k, v in pairs(props) do
			d[k] = v;
		end
		local b = new("TextButton", d, kids);
		press(b);
		return b;
	end
	local function ripple(btn, col)
		btn.ClipsDescendants = true;
		btn.MouseButton1Down:Connect(function()
			if not S.UIFX then
				return;
			end
			local sz = btn.AbsoluteSize;
			if ((sz.X < 1) or (sz.Y < 1)) then
				return;
			end
			local r = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0, 0),
				BackgroundColor3 = col or WHITE,
				BackgroundTransparency = 0.72,
				BorderSizePixel = 0,
				ZIndex = btn.ZIndex + 1,
				Parent = btn
			}, {
				corner(200)
			});
			tw(r, 0.5, {
				Size = UDim2.fromScale(2.4, (2.4 * sz.X) / sz.Y),
				BackgroundTransparency = 1
			});
			task.delay(0.55, function()
				r:Destroy();
			end);
		end);
	end
	local function gbutton(parent, props, text, a, b, ts)
		local btn = button(parent, props, {
			corner(10),
			grad(a or C.VIOLET, b or C.INDIGO, 20)
		});
		btn.BackgroundColor3 = WHITE;
		pcall(ripple, btn);
		local l = label(btn, {
			Size = UDim2.fromScale(1, 1),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = ts or 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 3
		});
		return btn, l;
	end
	local function glass(parent, props, r)
		local d = {
			BackgroundColor3 = C.PANEL2,
			BackgroundTransparency = 0.38,
			BorderSizePixel = 0,
			Parent = parent
		};
		for k, v in pairs(props or {}) do
			d[k] = v;
		end
		local f = new("Frame", d);
		corner(r or 14).Parent = f;
		local st = stroke(WHITE, 1, 0.91);
		st.Parent = f;
		if (props and props.LayoutOrder) then
			f.MouseEnter:Connect(function()
				if (f:GetAttribute("b0") == nil) then
					f:SetAttribute("b0", f.BackgroundTransparency);
				end
				tw(f, 0.18, {
					BackgroundTransparency = math.max(f:GetAttribute("b0") - 0.14, 0)
				});
				tw(st, 0.18, {
					Color = C.VIOLET,
					Transparency = 0.55
				});
			end);
			f.MouseLeave:Connect(function()
				tw(f, 0.25, {
					BackgroundTransparency = f:GetAttribute("b0") or 0.38
				});
				tw(st, 0.25, {
					Color = WHITE,
					Transparency = 0.91
				});
			end);
		end
		return f;
	end
	local function bar(parent, w, h, rot, col)
		return new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(w, h),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = rot or 0,
			BackgroundColor3 = col or C.TEXT,
			BorderSizePixel = 0,
			ZIndex = 8,
			Parent = parent
		}, {
			corner(2)
		});
	end
	local Switches, Hooks = {}, {};
	local function reg(key, fn)
		Switches[key] = Switches[key] or {} ;
		table.insert(Switches[key], fn);
	end
	local saveToken = 0;
	local function saveSoon()
		saveToken = saveToken + 1 ;
		local my = saveToken;
		task.delay(1, function()
			if (my ~= saveToken) then
				return;
			end
			pcall(function()
				if writefile then
					writefile(HUB.SaveFile, HttpService:JSONEncode(S));
				end
			end);
		end);
	end
	local toast;
	local function setState(key, v)
		S[key] = v;
		for _, f in ipairs(Switches[key] or {}) do
			pcall(f, v);
		end
		if Hooks[key] then
			pcall(Hooks[key], v);
		end
		saveSoon();
	end
	local PRESET_WIN = {
		Early = 520,
		Balanced = 450,
		Late = 380
	};
	Hooks.Preset = function(v)
		if PRESET_WIN[v] then
			setState("Window", PRESET_WIN[v]);
		end
	end;
	Hooks.Window = function(v)
		if ((PRESET_WIN[S.Preset] ~= v) and (S.Preset ~= "Custom")) then
			setState("Preset", "Custom");
		end
	end;
	local gui = new("ScreenGui", {
		Name = "MeenHubBladeBall",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	});
	do
		local ok = pcall(function()
			gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") ;
		end);
		if ( not ok or not gui.Parent) then
			gui.Parent = LP:WaitForChild("PlayerGui");
		end
	end
	local main = new("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(620, 400),
		BackgroundColor3 = C.BG,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		Parent = gui
	}, {
		corner(20)
	});
	local baseScale = 1;
	do
		local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720) ;
		baseScale = math.clamp(math.min(vp.X / 700, vp.Y / 460), 0.55, 1);
	end
	local mscale = new("UIScale", {
		Scale = baseScale * 0.85,
		Parent = main
	});
	local ring = stroke(C.VIOLET, 1.5, 0.15);
	ring.Parent = main;
	local ringG = new("UIGradient", {
		Color = ColorSequence.new({
			CK(0, C.VIOLET),
			CK(0.5, C.CYAN),
			CK(1, C.VIOLET)
		}),
		Parent = ring
	});
	bind(RunService.Heartbeat, function(dt)
		ringG.Rotation = (ringG.Rotation + (dt * 30)) % 360 ;
	end);
	local sky = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		ClipsDescendants = true,
		Visible = S.UIFX,
		Parent = main
	});
	do
		for _ = 1, 22 do
			local s = new("Frame", {
				Size = UDim2.fromOffset(2, 2),
				Position = UDim2.fromScale(math.random(), math.random()),
				BackgroundColor3 = WHITE,
				BackgroundTransparency = 0.3 + (math.random() * 0.5),
				BorderSizePixel = 0,
				Parent = sky
			}, {
				corner(1)
			});
			loopTween(s, 1.2 + (math.random() * 2), {
				BackgroundTransparency = 0.95
			}, math.random() * 2);
		end
	end
	Hooks.UIFX = function(v)
		sky.Visible = v;
	end;
	task.spawn(function()
		while alive do
			task.wait(2.5 + (math.random() * 4));
			if ( not alive or not sky.Parent) then
				break;
			end
			if (S.UIFX and main.Visible) then
				pcall(function()
					local x0, y0 = math.random() * 0.55 , math.random() * 0.35 ;
					local st = new("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(x0, y0),
						Size = UDim2.fromOffset(52, 2),
						Rotation = 28,
						BackgroundColor3 = WHITE,
						BorderSizePixel = 0,
						ZIndex = 2,
						Parent = sky
					}, {
						corner(1),
						new("UIGradient", {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 0)
							})
						})
					});
					tw(st, 0.85, {
						Position = UDim2.fromScale(x0 + 0.3, y0 + 0.38)
					}, Enum.EasingStyle.Sine, Enum.EasingDirection.In);
					task.delay(0.9, function()
						st:Destroy();
					end);
				end);
			end
		end
	end);
	local header = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 46),
		ZIndex = 5,
		Parent = main
	});
	local logoBox = new("Frame", {
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = C.PANEL2,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = header
	}, {
		corner(9),
		stroke(C.VIOLET, 1, 0.5)
	});
	local logoImg = new("ImageLabel", {
		Size = UDim2.new(1, - 4, 1, - 4),
		Position = UDim2.fromOffset(2, 2),
		BackgroundTransparency = 1,
		Image = HUB.Logo,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 7,
		Parent = logoBox
	}, {
		corner(8)
	});
	task.spawn(function()
		local t = 0;
		while logoImg.Parent and not logoImg.IsLoaded and (t < 6) do
			task.wait(0.25);
			t = t + 0.25 ;
		end
		if (logoImg.Parent and not logoImg.IsLoaded) then
			logoImg.ImageTransparency = 1;
			label(logoImg, {
				Size = UDim2.fromScale(1, 1),
				Text = "M",
				Font = Enum.Font.GothamBlack,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Center
			});
		end
	end);
	local titleLbl = label(header, {
		Position = UDim2.fromOffset(54, 5),
		Size = UDim2.fromOffset(240, 20),
		Text = HUB.Name .. "  |  BLADE BALL",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = WHITE,
		ZIndex = 6
	});
	local titleG = new("UIGradient", {
		Color = ColorSequence.new({
			CK(0, WHITE),
			CK(0.5, C.CYAN),
			CK(1, C.VIOLET)
		}),
		Parent = titleLbl
	});
	bind(RunService.Heartbeat, function(dt)
		titleG.Rotation = (titleG.Rotation + (dt * 45)) % 360 ;
	end);
	label(header, {
		Position = UDim2.fromOffset(54, 24),
		Size = UDim2.fromOffset(240, 16),
		Text = HUB.Version .. "  -  ULTIMATE COMBAT ENGINE",
		TextSize = 11,
		TextColor3 = C.MUTED,
		ZIndex = 6
	});
	local chip = glass(header, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, - 92, 0.5, 0),
		Size = UDim2.fromOffset(130, 24),
		ZIndex = 6
	}, 12);
	local chipLbl = label(chip, {
		Size = UDim2.fromScale(1, 1),
		Text = "-- FPS  --ms",
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = C.CYAN,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 7
	});
	local function winBtn(x, kind, col)
		local b = button(header, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, x, 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = C.PANEL2,
			BackgroundTransparency = 0.3,
			ZIndex = 7
		}, {
			corner(9)
		});
		if (kind == "close") then
			bar(b, 12, 2, 45, col);
			bar(b, 12, 2, - 45, col);
		else
			bar(b, 12, 2, 0, col);
		end
		return b;
	end
	local btnMin = winBtn( - 46, "min", C.TEXT);
	local btnClose = winBtn( - 12, "close", C.BAD);
	do
		local dragLayer = new("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = main
		});
		local dragging, dInput, start, startPos = false, nil, nil, nil;
		local function begin(i)
			if ((i.UserInputType == Enum.UserInputType.MouseButton1) or (i.UserInputType == Enum.UserInputType.Touch)) then
				dragging, dInput, start, startPos = true, i, i.Position, main.Position;
			end
		end
		header.InputBegan:Connect(begin);
		dragLayer.InputBegan:Connect(begin);
		bind(UIS.InputChanged, function(i)
			if not dragging then
				return;
			end
			if ((i == dInput) or (i.UserInputType == Enum.UserInputType.MouseMovement) or (i.UserInputType == Enum.UserInputType.Touch)) then
				local d = i.Position - start ;
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y);
			end
		end);
		bind(UIS.InputEnded, function(i)
			if ((i == dInput) or (i.UserInputType == Enum.UserInputType.MouseButton1) or (i.UserInputType == Enum.UserInputType.Touch)) then
				dragging = false;
			end
		end);
	end
	local side = glass(main, {
		Position = UDim2.fromOffset(12, 54),
		Size = UDim2.new(0, 138, 1, - 66),
		ZIndex = 3
	}, 14);
	new("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = side
	});
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = side
	});
	local content = new("Frame", {
		Position = UDim2.fromOffset(160, 54),
		Size = UDim2.new(1, - 172, 1, - 66),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = main
	});
	local TABS = {
		{
			"Dash",
			"แดชบอร์ด"
		},
		{
			"Home",
			"ควบคุม"
		},
		{
			"Combat",
			"ต่อสู้"
		},
		{
			"Visual",
			"ภาพ"
		},
		{
			"Safety",
			"ความปลอดภัย"
		},
		{
			"Settings",
			"ตั้งค่า"
		}
	};
	local pages, tabBtns, orders = {}, {}, {};
	local curPage;
	local function ord(p)
		orders[p] = (orders[p] or 0) + 1 ;
		return orders[p];
	end
	for idx, t in ipairs(TABS) do
		local name, thai = t[1], t[2];
		pages[name] = new("ScrollingFrame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = C.VIOLET,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
			ZIndex = 3,
			Parent = content
		}, {
			new("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			new("UIPadding", {
				PaddingRight = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6)
			})
		});
		local tb = button(side, {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = C.VIOLET,
			BackgroundTransparency = 1,
			LayoutOrder = idx,
			ZIndex = 4
		}, {
			corner(10)
		});
		pcall(ripple, tb);
		local dot = new("Frame", {
			Position = UDim2.fromOffset(10, 13),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = C.MUTED,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = tb
		}, {
			corner(3)
		});
		local tl = label(tb, {
			Position = UDim2.fromOffset(26, 0),
			Size = UDim2.new(1, - 30, 1, 0),
			Text = thai,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = C.MUTED,
			ZIndex = 5
		});
		local acc = new("Frame", {
			Position = UDim2.fromOffset(0, 8),
			Size = UDim2.fromOffset(3, 16),
			BackgroundColor3 = C.CYAN,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = tb
		}, {
			corner(2)
		});
		tb.MouseEnter:Connect(function()
			if (curPage ~= name) then
				tw(tb, 0.15, {
					BackgroundTransparency = 0.9
				});
			end
		end);
		tb.MouseLeave:Connect(function()
			if (curPage ~= name) then
				tw(tb, 0.2, {
					BackgroundTransparency = 1
				});
			end
		end);
		tabBtns[name] = {
			btn = tb,
			dot = dot,
			lbl = tl,
			acc = acc
		};
	end
	local function setPage(name)
		if (curPage == name) then
			return;
		end
		curPage = name;
		for n, p in pairs(pages) do
			p.Visible = n == name ;
		end
		for n, t in pairs(tabBtns) do
			local on = n == name ;
			tw(t.btn, 0.2, {
				BackgroundTransparency = (on and 0.75) or 1
			});
			tw(t.dot, 0.2, {
				BackgroundColor3 = (on and C.CYAN) or C.MUTED
			});
			tw(t.lbl, 0.2, {
				TextColor3 = (on and C.TEXT) or C.MUTED
			});
			tw(t.acc, 0.25, {
				BackgroundTransparency = (on and 0) or 1
			});
		end
		local i = 0;
		for _, c in ipairs(pages[name]:GetChildren()) do
			if c:IsA("GuiObject") then
				i = i + 1 ;
				popIn(c, math.min(i - 1, 10) * 0.03);
			end
		end
	end
	for n, t in pairs(tabBtns) do
		t.btn.MouseButton1Click:Connect(function()
			setPage(n);
		end);
	end
	do
		local fx = new("Frame", {
			Position = side.Position,
			Size = side.Size,
			BackgroundTransparency = 1,
			ZIndex = 6,
			Parent = main
		});
		local glow = new("Frame", {
			Size = UDim2.fromOffset(100, 32),
			BackgroundColor3 = C.VIOLET,
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 6,
			Parent = fx
		}, {
			corner(10)
		});
		local gst = stroke(C.CYAN, 1.2, 0.55);
		gst.Parent = glow;
		loopTween(gst, 1.1, {
			Transparency = 0.15
		});
		local cur, inited = 0, false;
		bind(RunService.Heartbeat, function(dt)
			local t = curPage and tabBtns[curPage] ;
			local ratio = side.AbsoluteSize.X / 138 ;
			if ( not t or (ratio <= 0)) then
				glow.Visible = false;
				return;
			end
			local ty = (t.btn.AbsolutePosition.Y - side.AbsolutePosition.Y) / ratio ;
			local tx = (t.btn.AbsolutePosition.X - side.AbsolutePosition.X) / ratio ;
			if not inited then
				cur, inited = ty, true;
			end
			cur = cur + ((ty - cur) * math.min(1, dt * 14)) ;
			glow.Visible = true;
			glow.Position = UDim2.fromOffset(tx, cur);
			glow.Size = UDim2.fromOffset(t.btn.AbsoluteSize.X / ratio, t.btn.AbsoluteSize.Y / ratio);
		end);
	end
	do
		local tst = stroke(C.VIOLET, 1, 1);
		local tl = label(main, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, - 14),
			Size = UDim2.fromOffset(300, 28),
			BackgroundColor3 = C.PANEL,
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Text = "",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 20
		}, {
			corner(14),
			tst
		});
		local id = 0;
		function toast(text)
			id = id + 1 ;
			local my = id;
			tl.Text = text;
			tw(tl, 0.2, {
				BackgroundTransparency = 0.1,
				TextTransparency = 0
			});
			tw(tst, 0.2, {
				Transparency = 0.5
			});
			task.delay(1.8, function()
				if ((my == id) and tl.Parent) then
					tw(tl, 0.3, {
						BackgroundTransparency = 1,
						TextTransparency = 1
					});
					tw(tst, 0.3, {
						Transparency = 1
					});
				end
			end);
		end
	end
	local function section(page, text)
		label(page, {
			Size = UDim2.new(1, - 6, 0, 22),
			Text = string.upper(text),
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = C.CYAN,
			LayoutOrder = ord(page),
			ZIndex = 4
		});
	end
	local function toggle(page, text, desc, key)
		local row = glass(page, {
			Size = UDim2.new(1, - 6, 0, (desc and 56) or 44),
			LayoutOrder = ord(page),
			ZIndex = 4
		}, 10);
		label(row, {
			Position = UDim2.fromOffset(14, (desc and 7) or 0),
			Size = UDim2.new(1, - 80, 0, (desc and 21) or 44),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 5
		});
		if desc then
			label(row, {
				Position = UDim2.fromOffset(14, 29),
				Size = UDim2.new(1, - 80, 0, 20),
				Text = desc,
				TextSize = 11,
				TextColor3 = C.MUTED,
				ZIndex = 5
			});
		end
		local sw = button(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, - 14, 0.5, 0),
			Size = UDim2.fromOffset(44, 24),
			BackgroundColor3 = (S[key] and C.VIOLET) or C.OFF,
			ZIndex = 5
		}, {
			corner(12)
		});
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, (S[key] and 23) or 3, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			ZIndex = 6,
			Parent = sw
		}, {
			corner(9)
		});
		local glow = stroke(C.CYAN, 2, (S[key] and 0.35) or 1);
		glow.Parent = sw;
		reg(key, function(v)
			tw(glow, 0.25, {
				Transparency = (v and 0.35) or 1
			});
			tw(knob, 0.22, {
				Position = UDim2.new(0, (v and 23) or 3, 0.5, 0)
			}, Enum.EasingStyle.Back);
			tw(sw, 0.2, {
				BackgroundColor3 = (v and C.VIOLET) or C.OFF
			});
		end);
		sw.MouseButton1Click:Connect(function()
			setState(key, not S[key]);
		end);
	end
	local function slider(page, text, key, mn, mx, step, fmt)
		local row = glass(page, {
			Size = UDim2.new(1, - 6, 0, 58),
			LayoutOrder = ord(page),
			ZIndex = 4
		}, 10);
		label(row, {
			Position = UDim2.fromOffset(14, 7),
			Size = UDim2.new(1, - 110, 0, 20),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 5
		});
		local val = label(row, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, - 14, 0, 7),
			Size = UDim2.fromOffset(90, 20),
			TextXAlignment = Enum.TextXAlignment.Right,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = C.CYAN,
			ZIndex = 5
		});
		local track = new("Frame", {
			Position = UDim2.new(0, 14, 0, 40),
			Size = UDim2.new(1, - 28, 0, 6),
			BackgroundColor3 = C.BG,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = row
		}, {
			corner(3)
		});
		local fill = new("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			ZIndex = 6,
			Parent = track
		}, {
			corner(3),
			grad(C.VIOLET, C.CYAN, 0)
		});
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			ZIndex = 7,
			Parent = track
		}, {
			corner(7)
		});
		local hit = new("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 28),
			Size = UDim2.new(1, - 28, 0, 28),
			ZIndex = 8,
			Parent = row
		});
		local function render(v)
			local a = math.clamp((v - mn) / (mx - mn), 0, 1);
			fill.Size = UDim2.fromScale(a, 1);
			knob.Position = UDim2.fromScale(a, 0.5);
			val.Text = (fmt and fmt(v)) or tostring(v) ;
		end
		render(S[key]);
		reg(key, render);
		local dragging = false;
		local function setFrom(x)
			local a = math.clamp((x - hit.AbsolutePosition.X) / math.max(hit.AbsoluteSize.X, 1), 0, 1);
			local v = math.clamp(math.floor(((mn + (a * (mx - mn))) / step) + 0.5) * step, mn, mx);
			setState(key, tonumber(string.format("%.3f", v)));
		end
		local function stopDrag()
			dragging = false;
			pcall(function()
				page.ScrollingEnabled = true;
			end);
		end
		hit.InputBegan:Connect(function(i)
			if ((i.UserInputType == Enum.UserInputType.MouseButton1) or (i.UserInputType == Enum.UserInputType.Touch)) then
				dragging = true;
				pcall(function()
					page.ScrollingEnabled = false;
				end);
				setFrom(i.Position.X);
			end
		end);
		bind(UIS.InputChanged, function(i)
			if (dragging and ((i.UserInputType == Enum.UserInputType.MouseMovement) or (i.UserInputType == Enum.UserInputType.Touch))) then
				setFrom(i.Position.X);
			end
		end);
		bind(UIS.InputEnded, function(i)
			if (dragging and ((i.UserInputType == Enum.UserInputType.MouseButton1) or (i.UserInputType == Enum.UserInputType.Touch))) then
				stopDrag();
			end
		end);
	end
	local function cycle(page, text, key, options, display)
		local row = glass(page, {
			Size = UDim2.new(1, - 6, 0, 44),
			LayoutOrder = ord(page),
			ZIndex = 4
		}, 10);
		label(row, {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, - 160, 1, 0),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 5
		});
		local function shown(v)
			return (display and display[v]) or tostring(v) ;
		end
		local b, l = gbutton(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, - 14, 0.5, 0),
			Size = UDim2.fromOffset(120, 28),
			ZIndex = 5
		}, shown(S[key]), C.VIOLET, C.INDIGO, 11);
		reg(key, function(v)
			l.Text = shown(v);
		end);
		b.MouseButton1Click:Connect(function()
			local n = 1;
			for i, o in ipairs(options) do
				if (o == S[key]) then
					n = i;
				end
			end
			setState(key, options[(n % # options) + 1 ]);
		end);
	end
	local function action(page, text, btnText, fn, col)
		local row = glass(page, {
			Size = UDim2.new(1, - 6, 0, 44),
			LayoutOrder = ord(page),
			ZIndex = 4
		}, 10);
		label(row, {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, - 160, 1, 0),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 5
		});
		local b = gbutton(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, - 14, 0.5, 0),
			Size = UDim2.fromOffset(120, 28),
			ZIndex = 5
		}, btnText, col or C.VIOLET, (col and Color3.fromRGB(190, 60, 60)) or C.INDIGO, 11);
		b.MouseButton1Click:Connect(function()
			pcall(fn);
		end);
	end
	local function note(page, text)
		label(page, {
			Size = UDim2.new(1, - 6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = text,
			TextSize = 11,
			TextColor3 = C.MUTED,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = ord(page),
			ZIndex = 4
		});
	end
	local Engine = {};
	local msFmt = function(v)
		return v .. " ms" ;
	end;
	local stFmt = function(v)
		return v .. " หน่วย" ;
	end;
	local UiTick = {};
	local fpsV, pingV, ballV, statusLbl, infoLbl, whyLbl, statLbl, safeLbl, banLbl, eventLbl;
	local chartBars = {};
	local UPDATES = {
		{
			ver = "V 1.1",
			tag = "NEW",
			col = C.CYAN,
			title = "อัปเดตใหญ่: หน้าตาใหม่ ลื่นกว่าเดิม",
			lines = {
				"ศูนย์กลางใหม่ที่รวมของที่ต้องดูไว้ในที่เดียว",
				"จังหวะหลายอย่างละเอียดและเนียนขึ้น ลองสัมผัสเองได้เลย",
				"รองรับ PC / Android / iOS (ปุ่มโลโก้ลากย้ายได้)",
				"แต่งเพิ่มอีกหลายจุด ลองเลื่อนดูแล้วจะเห็นเอง"
			}
		},
		{
			ver = "V 1.0",
			tag = "IMPROVE",
			col = C.VIOLET,
			title = "ระบบหลักรุ่นใหม่",
			lines = {
				"ปรับตัวตามสไตล์การเล่นของคุณได้ดีขึ้น",
				"มองสถานการณ์รอบตัวได้ละเอียดกว่าเดิม",
				"มีผู้ช่วยคอยดูความเรียบร้อยอยู่เบื้องหลัง"
			}
		}
	};
	local startClock = os.clock();
	local dashTimeLbl, dashRateLbl;
	local function platformText()
		local p = "";
		pcall(function()
			p = tostring(UIS:GetPlatform());
		end);
		if string.find(p, "Android", 1, true) then
			return "Android";
		end
		if string.find(p, "IOS", 1, true) then
			return "iOS";
		end
		if (string.find(p, "Windows", 1, true) or string.find(p, "OSX", 1, true) or string.find(p, "Linux", 1, true)) then
			return "PC";
		end
		return (IS_MOBILE and "มือถือ") or "PC" ;
	end
	do
		local pg = pages.Dash;
		local ban = glass(pg, {
			Size = UDim2.new(1, - 6, 0, 92),
			LayoutOrder = ord(pg),
			ZIndex = 4,
			ClipsDescendants = true
		}, 16);
		ban.BackgroundColor3 = C.VIOLET;
		ban.BackgroundTransparency = 0.72;
		local bg = new("UIGradient", {
			Rotation = 20,
			Color = ColorSequence.new({
				CK(0, C.VIOLET),
				CK(0.6, C.INDIGO),
				CK(1, C.CYAN)
			}),
			Parent = ban
		});
		bind(RunService.Heartbeat, function(dt)
			bg.Rotation = (bg.Rotation + (dt * 18)) % 360 ;
		end);
		local shine = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale( - 0.3, 0.5),
			Size = UDim2.new(0, 60, 2, 0),
			Rotation = 20,
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 0.88,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = ban
		});
		task.spawn(function()
			while alive and ban.Parent do
				shine.Position = UDim2.fromScale( - 0.3, 0.5);
				local tn = tw(shine, 1.6, {
					Position = UDim2.fromScale(1.3, 0.5)
				}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);
				tn.Completed:Wait();
				task.wait(3.5);
			end
		end);
		local lbox = new("Frame", {
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.fromOffset(60, 60),
			BackgroundColor3 = C.BG,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ZIndex = 6,
			Parent = ban
		}, {
			corner(16),
			stroke(WHITE, 1.5, 0.5)
		});
		local limg = new("ImageLabel", {
			Size = UDim2.new(1, - 8, 1, - 8),
			Position = UDim2.fromOffset(4, 4),
			BackgroundTransparency = 1,
			Image = HUB.Logo,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 7,
			Parent = lbox
		}, {
			corner(12)
		});
		loopTween(lbox, 2.2, {
			Rotation = 4
		});
		local function greeting()
			local h = tonumber(os.date("%H")) or 12 ;
			if (h < 5) then
				return "ดึกแล้วนะ";
			elseif (h < 12) then
				return "อรุณสวัสดิ์";
			elseif (h < 17) then
				return "สวัสดียามบ่าย";
			elseif (h < 21) then
				return "สวัสดียามเย็น";
			end
			return "ราตรีสวัสดิ์";
		end
		local mhl = label(ban, {
			Position = UDim2.fromOffset(88, 14),
			Size = UDim2.new(1, - 210, 0, 28),
			Text = "MEEN HUB",
			Font = Enum.Font.GothamBlack,
			TextSize = 24,
			TextColor3 = WHITE,
			ZIndex = 6
		});
		pcall(function()
			local sg = new("UIGradient", {
				Color = ColorSequence.new({
					CK(0, WHITE),
					CK(0.5, C.CYAN),
					CK(1, WHITE)
				}),
				Offset = Vector2.new( - 1, 0),
				Parent = mhl
			});
			loopTween(sg, 1.6, {
				Offset = Vector2.new(1, 0)
			});
		end);
		label(ban, {
			Position = UDim2.fromOffset(88, 44),
			Size = UDim2.new(1, - 210, 0, 18),
			Text = "Blade Ball  •  " .. HUB.Version .. "  •  " .. greeting() .. " " .. LP.DisplayName,
			TextSize = 12,
			TextColor3 = C.TEXT,
			ZIndex = 6
		});
		local clockLbl = label(ban, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, - 16, 0, 14),
			Size = UDim2.fromOffset(100, 28),
			Text = os.date("%H:%M"),
			Font = Enum.Font.GothamBlack,
			TextSize = 22,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = WHITE,
			ZIndex = 6
		});
		label(ban, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, - 16, 0, 42),
			Size = UDim2.fromOffset(100, 14),
			Text = os.date("%d/%m/%Y"),
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = C.MUTED,
			ZIndex = 6
		});
		UiTick[ # UiTick + 1 ] = function()
			local t = os.date("%H:%M");
			if (clockLbl.Text ~= t) then
				clockLbl.Text = t;
			end
		end;
		pcall(function()
			for _ = 1, 9 do
				local sz, x = math.random(2, 4), math.random();
				local p = new("Frame", {
					Size = UDim2.fromOffset(sz, sz),
					Position = UDim2.fromScale(x, 1.1),
					BackgroundColor3 = WHITE,
					BackgroundTransparency = 0.45,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = ban
				}, {
					corner(3)
				});
				TweenService:Create(p, TweenInfo.new(3 + (math.random() * 3), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, - 1, false, math.random() * 3), {
					Position = UDim2.fromScale(x, - 0.15),
					BackgroundTransparency = 1
				}):Play();
			end
		end);
		local pill = new("Frame", {
			Position = UDim2.fromOffset(88, 66),
			Size = UDim2.fromOffset(98, 18),
			BackgroundColor3 = C.BG,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			ZIndex = 6,
			Parent = ban
		}, {
			corner(9)
		});
		local pdot = new("Frame", {
			Position = UDim2.fromOffset(8, 5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundColor3 = C.OK,
			BorderSizePixel = 0,
			ZIndex = 7,
			Parent = pill
		}, {
			corner(4)
		});
		loopTween(pdot, 0.8, {
			BackgroundTransparency = 0.7
		});
		label(pill, {
			Position = UDim2.fromOffset(22, 0),
			Size = UDim2.new(1, - 26, 1, 0),
			Text = "ออนไลน์ • " .. platformText(),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextColor3 = C.OK,
			ZIndex = 7
		});
		local row = new("Frame", {
			Size = UDim2.new(1, - 6, 0, 60),
			BackgroundTransparency = 1,
			LayoutOrder = ord(pg),
			ZIndex = 4,
			Parent = pg
		});
		local function card(i, title)
			local f = glass(row, {
				Position = UDim2.new((i - 1) / 3, ((i > 1) and 3) or 0, 0, 0),
				Size = UDim2.new(1 / 3, - 4, 1, 0),
				ZIndex = 4
			}, 12);
			label(f, {
				Position = UDim2.fromOffset(12, 5),
				Size = UDim2.new(1, - 24, 0, 16),
				Text = title,
				TextSize = 11,
				TextColor3 = C.MUTED,
				ZIndex = 5
			});
			return label(f, {
				Position = UDim2.fromOffset(12, 25),
				Size = UDim2.new(1, - 24, 0, 28),
				Text = "--",
				Font = Enum.Font.GothamBold,
				TextSize = 19,
				ZIndex = 5
			});
		end
		dashTimeLbl = card(1, "เวลาใช้งาน");
		dashRateLbl = card(2, "อัตราตีโต้");
		card(3, "อุปกรณ์").Text = platformText();
		pcall(function()
			local box = glass(pg, {
				Size = UDim2.new(1, - 6, 0, 78),
				LayoutOrder = ord(pg),
				ZIndex = 4
			}, 12);
			local function meter(y, title)
				label(box, {
					Position = UDim2.fromOffset(14, y),
					Size = UDim2.new(0.5, - 14, 0, 14),
					Text = title,
					TextSize = 11,
					TextColor3 = C.MUTED,
					ZIndex = 5
				});
				local vl = label(box, {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, - 14, 0, y),
					Size = UDim2.fromOffset(90, 14),
					Text = "--",
					TextSize = 11,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 5
				});
				local track = new("Frame", {
					Position = UDim2.new(0, 14, 0, y + 17),
					Size = UDim2.new(1, - 28, 0, 6),
					BackgroundColor3 = C.BG,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = box
				}, {
					corner(3)
				});
				local fill = new("Frame", {
					Size = UDim2.fromScale(0.02, 1),
					BackgroundColor3 = C.OK,
					BorderSizePixel = 0,
					ZIndex = 6,
					Parent = track
				}, {
					corner(3)
				});
				return function(a, txt, col)
					tw(fill, 0.3, {
						Size = UDim2.fromScale(math.clamp(a, 0.02, 1), 1),
						BackgroundColor3 = col
					});
					vl.Text, vl.TextColor3 = txt, col;
				end;
			end
			local setFps, setPing = meter(8, "ความลื่น"), meter(42, "ความหน่วง");
			local lastM = 0;
			UiTick[ # UiTick + 1 ] = function(now, fps, ping)
				if ((now - lastM) < 0.4) then
					return;
				end
				lastM = now;
				fps, ping = tonumber(fps) or 0 , tonumber(ping) or 0 ;
				setFps(fps / 120, fps .. " FPS", ((fps >= 50) and C.OK) or ((fps >= 30) and C.WARN) or C.BAD);
				setPing(1 - (ping / 250), math.floor(ping) .. " ms", ((ping <= 80) and C.OK) or ((ping <= 160) and C.WARN) or C.BAD);
			end;
		end);
		pcall(function()
			local chart = glass(pg, {
				Size = UDim2.new(1, - 6, 0, 84),
				LayoutOrder = ord(pg),
				ZIndex = 4
			}, 12);
			label(chart, {
				Position = UDim2.fromOffset(12, 5),
				Size = UDim2.new(1, - 24, 0, 16),
				Text = "ประวัติปิง",
				TextSize = 11,
				TextColor3 = C.MUTED,
				ZIndex = 5
			});
			local area = new("Frame", {
				Position = UDim2.fromOffset(12, 26),
				Size = UDim2.new(1, - 24, 0, 50),
				BackgroundTransparency = 1,
				ZIndex = 5,
				Parent = chart
			});
			local NB, bars, hist = 28, {}, {};
			for i = 1, NB do
				hist[i] = 0;
				bars[i] = new("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new((i - 1) / NB, 1, 1, 0),
					Size = UDim2.new(1 / NB, - 2, 0.05, 0),
					BackgroundColor3 = C.CYAN,
					BackgroundTransparency = 0.3,
					BorderSizePixel = 0,
					ZIndex = 6,
					Parent = area
				}, {
					corner(2)
				});
			end
			local lastH = 0;
			UiTick[ # UiTick + 1 ] = function(now, _, ping)
				if ((now - lastH) < 1) then
					return;
				end
				lastH = now;
				table.remove(hist, 1);
				hist[NB] = tonumber(ping) or 0 ;
				for i = 1, NB do
					local v = hist[i];
					tw(bars[i], 0.4, {
						Size = UDim2.new(1 / NB, - 2, math.clamp(v / 250, 0.05, 1), 0),
						BackgroundColor3 = ((v <= 80) and C.CYAN) or ((v <= 160) and C.WARN) or C.BAD
					});
				end
			end;
		end);
		pcall(function()
			local srow = new("Frame", {
				Size = UDim2.new(1, - 6, 0, 60),
				BackgroundTransparency = 1,
				LayoutOrder = ord(pg),
				ZIndex = 4,
				Parent = pg
			});
			local function shortcut(i, thai, sub, page, a, b)
				local btn = button(srow, {
					Position = UDim2.new((i - 1) / 3, ((i > 1) and 3) or 0, 0, 0),
					Size = UDim2.new(1 / 3, - 4, 1, 0),
					BackgroundColor3 = WHITE,
					ZIndex = 4
				}, {
					corner(12),
					grad(a, b, 25)
				});
				label(btn, {
					Position = UDim2.fromOffset(12, 9),
					Size = UDim2.new(1, - 24, 0, 22),
					Text = thai,
					Font = Enum.Font.GothamBlack,
					TextSize = 15,
					ZIndex = 5
				});
				label(btn, {
					Position = UDim2.fromOffset(12, 33),
					Size = UDim2.new(1, - 24, 0, 16),
					Text = sub,
					TextSize = 10,
					TextTransparency = 0.2,
					ZIndex = 5
				});
				btn.MouseButton1Click:Connect(function()
					setPage(page);
				end);
				pcall(ripple, btn);
			end
			shortcut(1, "ต่อสู้", "ปรับให้ถูกใจ", "Combat", C.VIOLET, C.INDIGO);
			shortcut(2, "ภาพ", "แต่งให้สวยขึ้น", "Visual", C.INDIGO, C.CYAN);
			shortcut(3, "ปลอดภัย", "อุ่นใจกว่าเดิม", "Safety", C.CYAN, C.VIOLET);
		end);
		section(pg, "วิธีใช้คร่าวๆ");
		pcall(function()
			local steps = {
				{
					"1.",
					"เปิดระบบ",
					"เปิดสวิตช์ในหน้าต่อสู้ หรือกด X (พาร์รี่) / C (สแปม) บนคอม"
				},
				{
					"2.",
					"ปรับจังหวะ",
					"ถ้ากดช้าหรือเร็วไป ไปเลือกพรีเซ็ตในหน้าต่อสู้ให้ตรงกับปิงของเรา"
				},
				{
					"3.",
					"ซ่อนเมนู",
					"กด RightShift หรือแตะโลโก้ที่ลอยอยู่ตอนเล่น"
				}
			};
			local box = glass(pg, {
				Size = UDim2.new(1, - 6, 0, ( # steps * 46) + 10),
				LayoutOrder = ord(pg),
				ZIndex = 4
			}, 12);
			for i, s in ipairs(steps) do
				local y = 8 + ((i - 1) * 46) ;
				label(box, {
					Position = UDim2.fromOffset(14, y + 2),
					Size = UDim2.fromOffset(24, 18),
					Text = s[1],
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextColor3 = C.CYAN,
					ZIndex = 5
				});
				label(box, {
					Position = UDim2.fromOffset(40, y + 2),
					Size = UDim2.new(1, - 52, 0, 18),
					Text = s[2],
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					ZIndex = 5
				});
				label(box, {
					Position = UDim2.fromOffset(40, y + 20),
					Size = UDim2.new(1, - 52, 0, 16),
					Text = s[3],
					TextSize = 10,
					TextColor3 = C.MUTED,
					ZIndex = 5
				});
			end
		end);
		section(pg, "ถามบ่อย");
		do
			local FAQ = {
				{
					"ออโต้พาร์รี่ทำงานยังไง",
					"ตอนบอลใกล้จะถึงตัว สคริปต์จะกดป้องกันให้เอง โดยดูจากความเร็วบอลกับปิงของเรา กดครั้งเดียวต่อรอบ ถ้าพลาดจะกดซ้ำให้"
				},
				{
					"ออโต้สแปมต่างจากพาร์รี่ยังไง",
					"สแปมจะกดรัวตอนที่บอลเล็งมาที่เราและอยู่ในระยะ ปรับความเร็วกับระยะได้ในหน้าต่อสู้"
				},
				{
					"พรีเซ็ตเร็ว กลาง ช้า คืออะไร",
					"คือการเลื่อนจังหวะกด ถ้ากดช้าไปลองเลือกเร็ว ถ้ากดเร็วเกินไปลองเลือกช้า"
				},
				{
					"ทำไมในช่องเช็กเครื่องบางอันเป็นสีแดง",
					"แดงแปลว่าโปรแกรมที่ใช้รันสคริปต์ไม่มีคำสั่งนั้น สคริปต์จะข้ามส่วนนั้นไปเอง ไม่พัง แต่ฟีเจอร์บางอย่างอาจใช้ไม่ได้"
				},
				{
					"เมนูกระตุก เฟรมตก",
					"เข้าหน้าตั้งค่า ปิดเอฟเฟกต์ตกแต่ง หรือเปิดลดกราฟิก จะลื่นขึ้น"
				},
				{
					"ปุ่มลัดมีอะไรบ้าง",
					"RightShift ซ่อน/แสดงเมนู, X พาร์รี่, C สแปม, Delete ปิดทุกอย่างทันที, บนมือถือแตะโลโก้ที่ลอยอยู่"
				}
			};
			for _, qa in ipairs(FAQ) do
				local card = glass(pg, {
					Size = UDim2.new(1, - 6, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = ord(pg),
					ZIndex = 4
				}, 12);
				local body = new("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					ZIndex = 5,
					Parent = card
				});
				new("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = body
				});
				local head = button(body, {
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					ZIndex = 5
				});
				label(head, {
					Position = UDim2.fromOffset(14, 0),
					Size = UDim2.new(1, - 44, 1, 0),
					Text = qa[1],
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					ZIndex = 6
				});
				local icon = new("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, - 14, 0.5, 0),
					Size = UDim2.fromOffset(12, 12),
					BackgroundTransparency = 1,
					ZIndex = 6,
					Parent = head
				});
				local hbar = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(12, 2),
					BackgroundColor3 = C.CYAN,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = icon
				}, {
					corner(1)
				});
				local vbar = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(2, 12),
					BackgroundColor3 = C.CYAN,
					BorderSizePixel = 0,
					ZIndex = 7,
					Parent = icon
				}, {
					corner(1)
				});
				local ans = label(body, {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Text = qa[2],
					TextSize = 11,
					TextColor3 = C.MUTED,
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.None,
					TextYAlignment = Enum.TextYAlignment.Top,
					Visible = false,
					LayoutOrder = 2,
					ZIndex = 5
				}, {
					new("UIPadding", {
						PaddingLeft = UDim.new(0, 14),
						PaddingRight = UDim.new(0, 14),
						PaddingBottom = UDim.new(0, 12)
					})
				});
				local open = false;
				head.MouseButton1Click:Connect(function()
					open = not open;
					ans.Visible = open;
					tw(vbar, 0.2, {
						Size = UDim2.fromOffset(2, (open and 0) or 12)
					});
				end);
			end
		end
		pcall(function()
			local box = button(pg, {
				Size = UDim2.new(1, - 6, 0, 78),
				BackgroundColor3 = C.PANEL2,
				BackgroundTransparency = 0.38,
				LayoutOrder = ord(pg),
				ZIndex = 4
			}, {
				corner(12),
				stroke(C.CYAN, 1, 0.7)
			});
			label(box, {
				Position = UDim2.fromOffset(14, 7),
				Size = UDim2.new(1, - 28, 0, 14),
				Text = "เคล็ดลับ  (แตะเพื่อดูข้อต่อไป)",
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				TextColor3 = C.CYAN,
				ZIndex = 5
			});
			local tip = label(box, {
				Position = UDim2.fromOffset(14, 26),
				Size = UDim2.new(1, - 28, 0, 34),
				Text = "",
				TextSize = 12,
				TextWrapped = true,
				TextTruncate = Enum.TextTruncate.None,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 5
			});
			local TIPS = {
				"ลากปุ่มโลโก้ที่ลอยอยู่เพื่อย้ายไปไว้ตรงไหนก็ได้",
				"บน PC กด " .. HUB.ToggleKey.Name .. " เพื่อซ่อนหรือเปิดเมนู",
				"ค่าที่ปรับไว้จะถูกจำให้ ไม่ต้องตั้งใหม่ทุกรอบ",
				"ถ้าเครื่องเริ่มหน่วง ลองปิดเอฟเฟกต์ตกแต่งในหน้าตั้งค่า",
				"ปิงสูงๆ ลองใช้พรีเซ็ตแบบเร็ว",
				"ลากแถบด้านบนเพื่อย้ายหน้าต่างได้",
				"กด Delete ถ้าอยากปิดทุกระบบทันที",
				"ดูกราฟปิงด้านบน จะรู้ว่าตอนไหนเน็ตแกว่ง"
			};
			local dots = {};
			for i = 1, # TIPS do
				dots[i] = new("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 14 + ((i - 1) * 12), 1, - 8),
					Size = UDim2.fromOffset(8, 4),
					BackgroundColor3 = C.CYAN,
					BackgroundTransparency = 0.8,
					BorderSizePixel = 0,
					ZIndex = 5,
					Parent = box
				}, {
					corner(2)
				});
			end
			local idx, stamp = 0, 0;
			local function show(n)
				idx = n;
				stamp = stamp + 1 ;
				tip.Text = TIPS[idx];
				tip.TextTransparency = 1;
				tw(tip, 0.35, {
					TextTransparency = 0
				});
				for i, d in ipairs(dots) do
					tw(d, 0.25, {
						BackgroundTransparency = ((i == idx) and 0) or 0.8,
						Size = UDim2.fromOffset(((i == idx) and 18) or 8, 4)
					});
				end
			end
			show(1);
			box.MouseButton1Click:Connect(function()
				show((idx % # TIPS) + 1);
			end);
			task.spawn(function()
				local last, waited = - 1, 0;
				while alive an
... (91 KB left)
