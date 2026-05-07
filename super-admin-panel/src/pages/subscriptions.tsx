import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout';
import { Ban, CheckCircle, Clock, DollarSign, Eye, Power, PowerOff, XCircle } from 'lucide-react';

interface Subscription {
  id: string;
  companyName: string;
  plan: string;
  status: 'active' | 'inactive' | 'suspended' | 'cancelled';
  amount: number;
  billingCycle: string;
  startDate: string;
  endDate: string;
  nextBillingDate: string;
  autoRenewal: boolean;
}

const statusConfig = {
  active: { icon: CheckCircle, color: 'text-green-600', bg: 'bg-green-100' },
  inactive: { icon: Clock, color: 'text-yellow-600', bg: 'bg-yellow-100' },
  suspended: { icon: Ban, color: 'text-red-600', bg: 'bg-red-100' },
  cancelled: { icon: XCircle, color: 'text-gray-600', bg: 'bg-gray-100' }
};

const SubscriptionsPage = () => {
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedSubscription, setSelectedSubscription] = useState<Subscription | null>(null);

  useEffect(() => {
    fetchSubscriptions();
  }, []);

  const fetchSubscriptions = async () => {
    try {
      const response = await fetch('http://localhost:8080/api/subscriptions');
      if (response.ok) {
        const data = await response.json();
        setSubscriptions(data);
      } else {
        console.error('Failed to fetch subscriptions');
      }
    } catch (error) {
      console.error('Error fetching subscriptions:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleToggleSubscription = async (subscriptionId: string, enable: boolean) => {
    try {
      const response = await fetch(`http://localhost:8080/api/subscriptions/${subscriptionId}/toggle`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ enabled: enable }),
      });

      if (response.ok) {
        // Refresh subscriptions list
        fetchSubscriptions();
      } else {
        console.error('Failed to toggle subscription');
      }
    } catch (error) {
      console.error('Error toggling subscription:', error);
    }
  };

  const handleViewDetails = (subscription: Subscription) => {
    setSelectedSubscription(subscription);
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-96">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-sky-600"></div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Subscriptions</h1>
            <p className="text-slate-600">Manage company subscriptions and billing</p>
          </div>
          <div className="flex gap-3">
            <button className="rounded-xl bg-sky-600 px-4 py-2 text-sm font-medium text-white hover:bg-sky-700">
              Create Subscription
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          <div className="rounded-2xl bg-white p-6 shadow-soft">
            <div className="flex items-center gap-3">
              <div className="rounded-xl bg-green-100 p-2">
                <CheckCircle className="h-5 w-5 text-green-600" />
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600">Active</p>
                <p className="text-2xl font-bold text-slate-900">
                  {subscriptions.filter(s => s.status === 'active').length}
                </p>
              </div>
            </div>
          </div>

          <div className="rounded-2xl bg-white p-6 shadow-soft">
            <div className="flex items-center gap-3">
              <div className="rounded-xl bg-yellow-100 p-2">
                <Clock className="h-5 w-5 text-yellow-600" />
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600">Suspended</p>
                <p className="text-2xl font-bold text-slate-900">
                  {subscriptions.filter(s => s.status === 'suspended').length}
                </p>
              </div>
            </div>
          </div>

          <div className="rounded-2xl bg-white p-6 shadow-soft">
            <div className="flex items-center gap-3">
              <div className="rounded-xl bg-sky-100 p-2">
                <DollarSign className="h-5 w-5 text-sky-600" />
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600">Monthly Revenue</p>
                <p className="text-2xl font-bold text-slate-900">
                  ₹{subscriptions.filter(s => s.status === 'active').reduce((sum, s) => sum + s.amount, 0)}
                </p>
              </div>
            </div>
          </div>

          <div className="rounded-2xl bg-white p-6 shadow-soft">
            <div className="flex items-center gap-3">
              <div className="rounded-xl bg-violet-100 p-2">
                <Ban className="h-5 w-5 text-violet-600" />
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600">Cancelled</p>
                <p className="text-2xl font-bold text-slate-900">
                  {subscriptions.filter(s => s.status === 'cancelled').length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Subscriptions Table */}
        <div className="rounded-2xl bg-white shadow-soft overflow-hidden">
          <div className="border-b border-slate-200 px-6 py-4">
            <h2 className="text-lg font-semibold text-slate-900">All Subscriptions</h2>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-slate-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Company
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Plan
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Amount
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Next Billing
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {subscriptions.map((subscription) => {
                  const StatusIcon = statusConfig[subscription.status].icon;
                  return (
                    <tr key={subscription.id} className="hover:bg-slate-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-slate-900">
                          {subscription.companyName}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-slate-900">{subscription.plan}</div>
                        <div className="text-xs text-slate-500">{subscription.billingCycle}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className={`inline-flex items-center gap-1.5 rounded-full px-2 py-1 text-xs font-medium ${statusConfig[subscription.status].bg} ${statusConfig[subscription.status].color}`}>
                          <StatusIcon className="h-3 w-3" />
                          {subscription.status.charAt(0).toUpperCase() + subscription.status.slice(1)}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-900">
                        ₹{subscription.amount}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-900">
                        {new Date(subscription.nextBillingDate).toLocaleDateString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => handleViewDetails(subscription)}
                            className="text-sky-600 hover:text-sky-900"
                          >
                            <Eye className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleToggleSubscription(
                              subscription.id,
                              subscription.status !== 'active'
                            )}
                            className={`${
                              subscription.status === 'active'
                                ? 'text-red-600 hover:text-red-900'
                                : 'text-green-600 hover:text-green-900'
                            }`}
                          >
                            {subscription.status === 'active' ? (
                              <PowerOff className="h-4 w-4" />
                            ) : (
                              <Power className="h-4 w-4" />
                            )}
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>

        {/* Subscription Details Modal */}
        {selectedSubscription && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-2xl max-w-md w-full p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-slate-900">Subscription Details</h3>
                <button
                  onClick={() => setSelectedSubscription(null)}
                  className="text-slate-400 hover:text-slate-600"
                >
                  <XCircle className="h-5 w-5" />
                </button>
              </div>

              <div className="space-y-3">
                <div>
                  <label className="text-sm font-medium text-slate-500">Company</label>
                  <p className="text-sm text-slate-900">{selectedSubscription.companyName}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-slate-500">Plan</label>
                  <p className="text-sm text-slate-900">{selectedSubscription.plan}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-slate-500">Status</label>
                  <p className="text-sm text-slate-900 capitalize">{selectedSubscription.status}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-slate-500">Amount</label>
                  <p className="text-sm text-slate-900">₹{selectedSubscription.amount} ({selectedSubscription.billingCycle})</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-slate-500">Start Date</label>
                  <p className="text-sm text-slate-900">{new Date(selectedSubscription.startDate).toLocaleDateString()}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-slate-500">End Date</label>
                  <p className="text-sm text-slate-900">{new Date(selectedSubscription.endDate).toLocaleDateString()}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-slate-500">Auto Renewal</label>
                  <p className="text-sm text-slate-900">{selectedSubscription.autoRenewal ? 'Enabled' : 'Disabled'}</p>
                </div>
              </div>

              <div className="flex gap-3 mt-6">
                <button
                  onClick={() => handleToggleSubscription(
                    selectedSubscription.id,
                    selectedSubscription.status !== 'active'
                  )}
                  className={`flex-1 rounded-xl px-4 py-2 text-sm font-medium ${
                    selectedSubscription.status === 'active'
                      ? 'bg-red-600 text-white hover:bg-red-700'
                      : 'bg-green-600 text-white hover:bg-green-700'
                  }`}
                >
                  {selectedSubscription.status === 'active' ? 'Suspend' : 'Activate'}
                </button>
                <button
                  onClick={() => setSelectedSubscription(null)}
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

export default SubscriptionsPage;