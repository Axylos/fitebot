Table = require 'cli-table2'

print_fites = (fites) ->
    config = {
        head: ['ID', 'Left', '', 'Right'],
        colWidths: [5, 60, 5, 60]

    }
    table = new Table(config)

    fites.forEach (fite) ->
        table.push([fite.rank, fmt_fiter(fite.left_fiter), 'VS', fmt_fiter(fite.right_fiter)])

    table.toString()


print_pending_fites = (fites) ->
    config = {
        head: ['Left', 'Right'],
        colWidths: [60, 60]

    }
    table = new Table(config)

    fites.forEach (fite) ->
        table.push([fite.left_fiter, fite.right_fiter])

    table.toString()

fmt_fiter = (fite) ->
    util.format "%s ("

module.exports = {
    print_pending_fites: print_pending_fites
    print_fites: print_fites
}
