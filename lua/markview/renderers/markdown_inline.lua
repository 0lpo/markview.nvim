local inline = {};

local spec = require("markview.spec");
local utils = require("markview.utils");
local entities = require("markview.entities");

local get_config = function (opt)
	return spec.get("markdown_inline", opt);
end

inline.__ns = {
	__call = function (self, key)
		return self[key] or self.default;
	end
}

inline.ns = {
	default = vim.api.nvim_create_namespace("markview/inline"),
};
setmetatable(inline.ns, inline.__ns)

inline.set_ns = function ()
	local ns_pref = get_config("use_seperate_ns");
	if not ns_pref then ns_pref = true; end

	local available = vim.api.nvim_get_namespaces();
	local ns_list = {
		["inline_codes"] = "markview/markdown_inline/inline_codes",
		["links"] = "markview/markdown_inline/links",
		["obsidian"] = "markview/markdown_inline/obsidian",
		["symbols"] = "markview/markdown_inline/symbols",
	};

	if ns_pref == true then
		for ns, name in pairs(ns_list) do
			if vim.list_contains(available, ns) == false then
				inline.ns[ns] = vim.api.nvim_create_namespace(name);
			end
		end
	end
end

inline.custom_config = function (config, value)
	if not config.custom or not value then
		return config;
	end

	for _, custom in ipairs(config.custom) do
		if custom.match_string and value:match(custom.match_string) then
			return vim.tbl_deep_extend("force", config, custom);
		end
	end

	return config;
end

inline.code_span = function (buffer, item)
	---+${func, Render Inline codes}
	local config = get_config("inline_codes");
	local range = item.range;

	if not config then
		return;
	end

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("inline_codes"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 1,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("inline_codes"), range.row_start, range.col_start + 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end - 1,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("inline_codes"), range.row_start, range.col_end - 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) },
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
end

inline.link_email = function (buffer, item)
	---+${func, Render Email links}
	local config = get_config("emails");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label)

	---+${custom, Draw the parts for the email}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 1,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start + 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end - 1,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_end - 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) },
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.link_image = function (buffer, item)
	---+${func, Render Image links}
	local config = get_config("images");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label)

	---+${custom, Draw the parts for the image}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.desc_start or (range.col_start + 1),
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.desc_start or range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.desc_end or range.col_end,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.desc_end or (range.col_end - 3), {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.link_hyperlink = function (buffer, item)
	---+${func, Render normal links}
	local config = get_config("hyperlinks");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label);

	---+${custom, Draw the parts for the image}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.desc_start or (range.col_start + 1),
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.desc_start or range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.desc_end or range.col_end,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.desc_end or (range.col_end - 3), {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	--_
	---_
end

inline.link_shortcut = function (buffer, item)
	---+${func, Render Shortcut links}
	local config = get_config("hyperlinks");
	local range = item.range;

	if not config then
		return;
	end

	---+${custom, Draw the parts for the shortcut links}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 1,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start + 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end - 1,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_end - 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.link_uri_autolink = function (buffer, item)
	---+${func, Render URI links}
	local config = get_config("uri_autolinks");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label);

	---+${custom, Draw the parts for the autolinks}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 1,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("links"), range.row_start, range.col_end - 1, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.link_internal = function (buffer, item)
	---+${func, Render Obsidian's internal links}
	local config = get_config("internal_links");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label);

	---+${custom, Draw the parts for the internal links}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.alias_start or (range.col_start + 2),
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.alias_ene or (range.col_end - 2), {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.link_embed_file = function (buffer, item)
	---+${func, Render Obsidian's embed file links}
	local config = get_config("embed_files");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label);

	---+${custom, Draw the parts for the embed file links}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 2,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.alias_ene or (range.col_end - 2), {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.link_block_ref = function (buffer, item)
	---+${func, Render Obsidian's block reference links}
	local config = get_config("block_references");
	local range = item.range;

	if not config then
		return;
	end

	config = inline.custom_config(config, item.label);

	---+${custom, Draw the parts for the embed file links}
	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 2,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.corner_left or "", utils.set_hl(config.corner_left_hl or config.hl) },
			{ config.padding_left or "", utils.set_hl(config.padding_left_hl or config.hl) },

			{ config.icon or "", utils.set_hl(config.icon_hl or config.hl) }
		},

		hl_mode = "combine"
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		hl_group = utils.set_hl(config.hl)
	});

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("obsidian"), range.row_start, range.alias_ene or (range.col_end - 2), {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.padding_right or "", utils.set_hl(config.padding_right_hl or config.hl) },
			{ config.corner_right or "", utils.set_hl(config.corner_right_hl or config.hl) }
		},

		hl_mode = "combine"
	});
	---_
	---_
end

inline.escaped = function (buffer, item)
	---+${func, Render Escaped characters}
	local config = get_config("escapes");
	local range = item.range;

	if not config then
		return;
	end

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("symbols"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_start + 1,
		conceal = ""
	});
	---_
end

inline.entity = function (buffer, item)
	---+${func, Renders Character entities}
	local config = get_config("entities");
	local range = item.range;

	if not config then
		return;
	elseif not entities.get(item.text) then
		return;
	end

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("symbols"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ entities.get(item.text), utils.set_hl(config.hl) }
		}
	});
	---_
end

inline.checkbox = function (buffer, item)
	---+${func, Renders Checkboxes}
	local config = get_config("checkboxes");
	local range = item.range;

	if not config then
		return;
	else
		local found_state = false;

		if item.text == "X" or item.text == "x" and config.checked then
			config = config.checked;
			goto continue;
		elseif item.text == " " and config.unchecked then
			config = config.unchecked;
			goto continue;
		end

		for _, state in ipairs(config.custom or {}) do
			if item.text == state.match_string then
				config = state;
				found_state = true;
				break;
			end
		end

		if found_state == false then
			return;
		end

		::continue::
	end

	vim.api.nvim_buf_set_extmark(buffer, inline.ns("checkboxes"), range.row_start, range.col_start, {
		undo_restore = false, invalidate = true,
		end_col = range.col_end,
		conceal = "",

		virt_text_pos = "inline",
		virt_text = {
			{ config.text, utils.set_hl(config.hl) }
		}
	});
	---_
end

inline.render = function (buffer, content)
	inline.set_ns();

	for _, item in ipairs(content or {}) do
		-- pcall(inline[item.class:gsub("^inline_", "")], buffer, item);
		inline[item.class:gsub("^inline_", "")](buffer, item);
	end
end

inline.clear = function (buffer, ignore_ns, from, to)
	for name, ns in pairs(inline.ns) do
		if ignore_ns and vim.list_contains(ignore_ns, name) == false then
			vim.api.nvim_buf_clear_namespace(buffer, ns, from or 0, to or -1);
		end
	end
end

return inline;
