import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout';
import { MapPin, Users, Clock, AlertTriangle } from 'lucide-react';

interface EmployeeLocation {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  status: 'in_zone' | 'nearby' | 'outside';
  lastUpdate: string;
  zoneName?: string;
}

interface Zone {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  radius: number;
  color: string;
}

const LiveMapPage = () => {
  const [employees, setEmployees] = useState<EmployeeLocation[]>([]);
  const [zones, setZones] = useState<Zone[]>([]);
  const [selectedEmployee, setSelectedEmployee] = useState<EmployeeLocation | null>(null);
  const [mapLoaded, setMapLoaded] = useState(false);

  useEffect(() => {
    // Mock data - replace with actual API calls
    const mockEmployees: EmployeeLocation[] = [
      {
        id: '1',
        name: 'Rahul Sharma',
        latitude: 28.6139,
        longitude: 77.2090,
        status: 'in_zone',
        lastUpdate: '2 minutes ago',
        zoneName: 'Delhi Office'
      },
      {
        id: '2',
        name: 'Priya Singh',
        latitude: 28.6200,
        longitude: 77.2100,
        status: 'nearby',
        lastUpdate: '5 minutes ago'
      },
      {
        id: '3',
        name: 'Amit Kumar',
        latitude: 28.6300,
        longitude: 77.2200,
        status: 'outside',
        lastUpdate: '1 hour ago'
      }
    ];

    const mockZones: Zone[] = [
      {
        id: '1',
        name: 'Delhi Office',
        latitude: 28.6139,
        longitude: 77.2090,
        radius: 500,
        color: '#2563EB'
      },
      {
        id: '2',
        name: 'Mumbai Branch',
        latitude: 19.0760,
        longitude: 72.8777,
        radius: 300,
        color: '#7C3AED'
      }
    ];

    setEmployees(mockEmployees);
    setZones(mockZones);

    // Load Google Maps script
    if (!window.google && !document.querySelector('script[src*="maps.googleapis.com"]')) {
      const script = document.createElement('script');
      script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=geometry`;
      script.async = true;
      script.defer = true;
      script.onload = () => setMapLoaded(true);
      document.head.appendChild(script);
    } else {
      setMapLoaded(true);
    }
  }, []);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'in_zone': return 'text-green-600 bg-green-100';
      case 'nearby': return 'text-yellow-600 bg-yellow-100';
      case 'outside': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'in_zone': return '🟢';
      case 'nearby': return '🟡';
      case 'outside': return '🔴';
      default: return '⚪';
    }
  };

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Live Map</h1>
            <p className="text-slate-600">Real-time employee location tracking</p>
          </div>
          <div className="flex items-center gap-3">
            <div className="rounded-xl bg-green-100 px-3 py-1 text-sm font-medium text-green-700">
              {employees.filter(e => e.status === 'in_zone').length} In Zone
            </div>
            <div className="rounded-xl bg-yellow-100 px-3 py-1 text-sm font-medium text-yellow-700">
              {employees.filter(e => e.status === 'nearby').length} Nearby
            </div>
            <div className="rounded-xl bg-red-100 px-3 py-1 text-sm font-medium text-red-700">
              {employees.filter(e => e.status === 'outside').length} Outside
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Map Container */}
          <div className="lg:col-span-3">
            <div className="rounded-2xl bg-white p-6 shadow-soft">
              <div className="mb-4 flex items-center justify-between">
                <h2 className="text-lg font-semibold text-slate-900">Location Map</h2>
                <div className="flex items-center gap-2 text-sm text-slate-500">
                  <Clock className="h-4 w-4" />
                  Auto-refresh every 30s
                </div>
              </div>

              <div className="h-[500px] rounded-xl bg-slate-100 relative overflow-hidden">
                {mapLoaded ? (
                  <div className="w-full h-full bg-gradient-to-br from-sky-100 to-violet-100 flex items-center justify-center">
                    <div className="text-center">
                      <MapPin className="h-12 w-12 text-sky-600 mx-auto mb-2" />
                      <p className="text-slate-600 font-medium">Google Maps Integration</p>
                      <p className="text-sm text-slate-500">Interactive map would load here</p>
                      <p className="text-xs text-slate-400 mt-2">
                        Employees: {employees.length} | Zones: {zones.length}
                      </p>
                    </div>
                  </div>
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-sky-600"></div>
                  </div>
                )}

                {/* Employee markers overlay (mock) */}
                <div className="absolute inset-0 pointer-events-none">
                  {employees.slice(0, 3).map((employee, index) => (
                    <div
                      key={employee.id}
                      className="absolute w-3 h-3 rounded-full border-2 border-white shadow-lg"
                      style={{
                        backgroundColor: employee.status === 'in_zone' ? '#10B981' :
                                       employee.status === 'nearby' ? '#F59E0B' : '#EF4444',
                        left: `${20 + index * 25}%`,
                        top: `${30 + index * 20}%`
                      }}
                    />
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Employee List */}
            <div className="rounded-2xl bg-white p-6 shadow-soft">
              <div className="mb-4 flex items-center gap-2">
                <Users className="h-5 w-5 text-slate-600" />
                <h3 className="font-semibold text-slate-900">Employees ({employees.length})</h3>
              </div>

              <div className="space-y-3 max-h-60 overflow-y-auto">
                {employees.map((employee) => (
                  <div
                    key={employee.id}
                    className={`rounded-xl p-3 cursor-pointer transition ${
                      selectedEmployee?.id === employee.id ? 'bg-sky-50 border border-sky-200' : 'hover:bg-slate-50'
                    }`}
                    onClick={() => setSelectedEmployee(employee)}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-lg">{getStatusIcon(employee.status)}</span>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-slate-900 truncate">
                          {employee.name}
                        </p>
                        <p className="text-xs text-slate-500">{employee.lastUpdate}</p>
                      </div>
                    </div>
                    {employee.zoneName && (
                      <p className="text-xs text-sky-600 mt-1">{employee.zoneName}</p>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Zones List */}
            <div className="rounded-2xl bg-white p-6 shadow-soft">
              <div className="mb-4 flex items-center gap-2">
                <MapPin className="h-5 w-5 text-slate-600" />
                <h3 className="font-semibold text-slate-900">Zones ({zones.length})</h3>
              </div>

              <div className="space-y-3">
                {zones.map((zone) => (
                  <div key={zone.id} className="rounded-xl p-3 bg-slate-50">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-3 h-3 rounded-full"
                        style={{ backgroundColor: zone.color }}
                      />
                      <div>
                        <p className="text-sm font-medium text-slate-900">{zone.name}</p>
                        <p className="text-xs text-slate-500">{zone.radius}m radius</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Alerts */}
            <div className="rounded-2xl bg-white p-6 shadow-soft">
              <div className="mb-4 flex items-center gap-2">
                <AlertTriangle className="h-5 w-5 text-orange-600" />
                <h3 className="font-semibold text-slate-900">Alerts</h3>
              </div>

              <div className="space-y-3">
                <div className="rounded-xl bg-red-50 p-3 border border-red-200">
                  <p className="text-sm font-medium text-red-900">Zone Exit Alert</p>
                  <p className="text-xs text-red-700">Amit Kumar left office zone</p>
                  <p className="text-xs text-red-600 mt-1">1 hour ago</p>
                </div>

                <div className="rounded-xl bg-yellow-50 p-3 border border-yellow-200">
                  <p className="text-sm font-medium text-yellow-900">GPS Spoofing</p>
                  <p className="text-xs text-yellow-700">Unusual location detected</p>
                  <p className="text-xs text-yellow-600 mt-1">15 minutes ago</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Employee Details Modal */}
        {selectedEmployee && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-2xl max-w-md w-full p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-slate-900">Employee Details</h3>
                <button
                  onClick={() => setSelectedEmployee(null)}
                  className="text-slate-400 hover:text-slate-600"
                >
                  ×
                </button>
              </div>

              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{getStatusIcon(selectedEmployee.status)}</span>
                  <div>
                    <p className="font-semibold text-slate-900">{selectedEmployee.name}</p>
                    <p className="text-sm text-slate-500 capitalize">{selectedEmployee.status.replace('_', ' ')}</p>
                  </div>
                </div>

                <div>
                  <label className="text-sm font-medium text-slate-500">Last Update</label>
                  <p className="text-sm text-slate-900">{selectedEmployee.lastUpdate}</p>
                </div>

                {selectedEmployee.zoneName && (
                  <div>
                    <label className="text-sm font-medium text-slate-500">Current Zone</label>
                    <p className="text-sm text-slate-900">{selectedEmployee.zoneName}</p>
                  </div>
                )}

                <div>
                  <label className="text-sm font-medium text-slate-500">Coordinates</label>
                  <p className="text-sm text-slate-900 font-mono">
                    {selectedEmployee.latitude.toFixed(6)}, {selectedEmployee.longitude.toFixed(6)}
                  </p>
                </div>
              </div>

              <div className="flex gap-3 mt-6">
                <button
                  onClick={() => setSelectedEmployee(null)}
                  className="flex-1 rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
};

export default LiveMapPage;
