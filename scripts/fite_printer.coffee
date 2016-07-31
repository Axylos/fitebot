Table = require 'cli-table2'

print_fites = (fites) ->
    config = {
        head: ['Left', 'Right'],
        colWidths: [60, 60]

    }
    table = new Table(config)

    fites.forEach (fite) ->
        table.push([fite.left_fiter, fite.right_fiter])

    table.toString()

module.exports = {
    print_fites: print_fites
}
