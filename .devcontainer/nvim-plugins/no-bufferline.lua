-- Отключаем bufferline (верхняя панель с открытыми buffers — выглядит как табы).
-- LazyVim показывает её по умолчанию; убираем целиком.
return {
  { "akinsho/bufferline.nvim", enabled = false },
}
