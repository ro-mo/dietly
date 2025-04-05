module AppointmentsHelper
  def status_color(status)
    case status
    when 'pending'
      'text-yellow-600'
    when 'confirmed'
      'text-green-600'
    when 'cancelled'
      'text-red-600'
    when 'completed'
      'text-blue-600'
    else
      'text-gray-600'
    end
  end
end 