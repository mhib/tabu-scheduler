require 'terminal-table'

class TableBuilder
  def initialize(result)
    @array = result[0]
    @cost = result[1]
  end

  def call
    costs = %w(min mid max).map { |e| "#{e}: #{@cost.public_send(e)}" }.join(', ')
    table = Terminal::Table.new(title: "Cost: #{costs}")
    groups, machines = groups_and_machines
    table.headings = machines.map(&:to_s)
    (0...building_count(groups)).each do |i|
      table << machines.map do |machine|
        el = groups[machine][i]
        el.respond_to?(:building) ? el.building : el
      end
    end
    table
  end

  private

  def groups_and_machines
    if @array.first.is_a? Array
      [@array.dup.tap { |e| e.unshift(nil) }, (1..@array.size).to_a]
    else
      groups = @array.group_by(&:machine)
      machines = groups.keys.sort
      [groups, machines]
    end
  end

  def building_count(groups)
    case groups
    when Hash
      groups.first[1].size
    when Array
      groups[1].size
    end
  end
end
