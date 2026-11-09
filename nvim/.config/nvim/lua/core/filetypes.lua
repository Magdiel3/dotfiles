vim.filetype.add({
    filename = {
        ['README'] = 'markdown',
    },
    pattern = {
        ['README%..*'] = 'markdown',
    },
})
