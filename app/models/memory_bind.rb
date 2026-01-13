# связка 2-х памятей
#
# kind - Вид связки: источник (Source) для списков икон,
#        опора (Base) - иконы личностей, подобие (Similar) - для установления подобия иконы иной иконе,
#        владелец (Host) - для владельцев предметов
class MemoryBind < ApplicationRecord
   belongs_to :memory
   belongs_to :bond_event, class_name: :Event
end
