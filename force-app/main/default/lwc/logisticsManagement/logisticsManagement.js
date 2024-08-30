import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrders from '@salesforce/apex/LogisticsManagementController.getOrders';
import getOrderCount from '@salesforce/apex/LogisticsManagementController.getOrderCount';
import getStatusOptions from '@salesforce/apex/LogisticsManagementController.getStatusOptions';
import getRouteOptions from '@salesforce/apex/LogisticsManagementController.getRouteOptions';
import getServiceResources from '@salesforce/apex/LogisticsManagementController.getServiceResources';
import createWorkOrders from '@salesforce/apex/LogisticsManagementController.createWorkOrders';

const PAGE_SIZE = 10;
const VISIBLE_PAGES = 4;

export default class LogisticsManagement extends LightningElement {
    @track effectiveDate;
    @track endDate;
    @track status;
    @track route;
    @track searchKey = '';
    @track pinCode = '';
    @track orders = [];
    @track error;
    @track statusOptions = [];
    @track routeOptions = [];
    @track currentPage = 1;
    @track totalRecords;
    @track totalPages;
    @track startRecord;
    @track endRecord;
    @track selectedRecordIds = new Set();
    @track showRecordsSection = false;
    @track isFiltersOpen = true;
    @track isRecordsOpen = false;
    @track showDriverModal = false;
    @track showTechnicianModal = false;
    @track serviceResources = [];
    @track selectedServiceResource;
    @track loading = false;

    @wire(getStatusOptions)
    wiredStatusOptions({ data, error }) {
        if (data) {
            this.statusOptions = data.map(status => ({ label: status, value: status }));
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRouteOptions)
    wiredRouteOptions({ data, error }) {
        if (data) {
            this.routeOptions = data.map(route => ({ label: route, value: route }));
        } else if (error) {
            this.error = error;
        }
    }

    getStatusClass(status) {
        switch (status) {
            case 'New': return 'status-new';
            case 'In-Process': return 'status-in-process';
            case 'Ready for Dispatch': return 'status-ready-for-dispatch';
            case 'Dispatched': return 'status-dispatched';
            case 'Delivered': return 'status-delivered';
            case 'Invoiced': return 'status-invoiced';
            case 'Paid': return 'status-paid';
            case 'Closed': return 'status-closed';
            case 'Returned': return 'status-returned';
            default: return '';
        }
    }

    handleEffectiveDateChange(event) {
        this.effectiveDate = event.target.value;
        this.refreshOrders();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.refreshOrders();
    }

    handleStatusChange(event) {
        this.status = event.target.value;
        this.refreshOrders();
    }

    handleRouteChange(event) {
        this.route = event.target.value;
        this.refreshOrders();
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.refreshOrders();
    }

    handlePinCodeChange(event) {
        this.pinCode = event.target.value;
        this.refreshOrders();
    }

    refreshOrders() {
        this.currentPage = 1;
        this.getFilteredOrders();
    }

    getFilteredOrders() {
        this.loading = true;
        getOrderCount({ effectiveDate: this.effectiveDate, endDate: this.endDate, status: this.status, route: this.route, searchKey: this.searchKey, pinCode: this.pinCode })
            .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(this.totalRecords / PAGE_SIZE);
                this.updateRecordRange();
                this.loadOrders();
            })
            .catch(error => {
                this.error = error;
                this.orders = [];
                this.showRecordsSection = true;
                this.isRecordsOpen = true;
                this.loading = false;
            });
    }

    loadOrders() {
        getOrders({ effectiveDate: this.effectiveDate, endDate: this.endDate, status: this.status, route: this.route, searchKey: this.searchKey, pinCode: this.pinCode, pageSize: PAGE_SIZE, pageNumber: this.currentPage })
            .then(result => {
                this.orders = result.map(order => ({
                    ...order,
                    selected: this.selectedRecordIds.has(order.Id),
                    statusClass: this.getStatusClass(order.Status),
                    AccountName: order.Account?.Name || '',
                    ContactName: order.Contact__r?.Name || '',
                    DeliveryAddress: `${order.Delivery_Address__Street__s || ''}, ${order.Delivery_Address__City__s || ''}, ${order.Delivery_Address__StateCode__s || ''}, ${order.Delivery_Address__PostalCode__s || ''}, ${order.Delivery_Address__CountryCode__s || ''}`
                }));
                this.error = undefined;
                this.showRecordsSection = true;
                this.isRecordsOpen = true;
                this.loading = false;
            })
            .catch(error => {
                this.error = error;
                this.orders = [];
                this.showRecordsSection = true;
                this.isRecordsOpen = true;
                this.loading = false;
            });
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateRecordRange();
            this.loadOrders();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updateRecordRange();
            this.loadOrders();
        }
    }

    handlePageChange(event) {
        this.currentPage = parseInt(event.target.dataset.page, 10);
        this.updateRecordRange();
        this.loadOrders();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * PAGE_SIZE + 1;
        this.endRecord = Math.min(this.currentPage * PAGE_SIZE, this.totalRecords);
    }

    get paginationControls() {
        const pages = [];
        const startPage = Math.max(1, this.currentPage - Math.floor(VISIBLE_PAGES / 2));
        const endPage = Math.min(this.totalPages, startPage + VISIBLE_PAGES - 1);

        for (let i = startPage; i <= endPage; i++) {
            pages.push({
                label: i,
                value: i,
                className: i === this.currentPage ? 'pagination-button active' : 'pagination-button'
            });
        }
        return pages;
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    handleCheckboxChange(event) {
        const recordId = event.target.dataset.recordId;
        if (event.target.checked) {
            this.selectedRecordIds.add(recordId);
        } else {
            this.selectedRecordIds.delete(recordId);
        }
    }

    handleSelectAllCheckboxChange(event) {
        const isSelected = event.target.checked;
        const updatedOrders = this.orders.map(order => {
            if (isSelected) {
                this.selectedRecordIds.add(order.Id);
            } else {
                this.selectedRecordIds.delete(order.Id);
            }
            return { ...order, selected: isSelected };
        });
        this.orders = [...updatedOrders];
    }

    clearAllFilters() {
        this.effectiveDate = null;
        this.endDate = null;
        this.status = null;
        this.route = null;
        this.pinCode = '';
        this.searchKey = '';
        this.orders = [];
        this.showRecordsSection = false;
        this.isRecordsOpen = false;
    }

    openAssignDriverModal() {
        if (this.selectedRecordIds.size > 0) {
            const selectedRoutes = [...this.selectedRecordIds].map(recordId => {
                const order = this.orders.find(order => order.Id === recordId);
                return order?.Route__c;
            }).filter(route => route);

            if (selectedRoutes.length > 0) {
                getServiceResources({ routes: selectedRoutes, resourceType: 'Driver' })
                    .then(result => {
                        this.serviceResources = result;
                        this.showDriverModal = true;
                    })
                    .catch(error => {
                        this.error = error;
                        this.showToast('Error', 'An error occurred while fetching drivers.', 'error');
                    });
            } else {
                this.showToast('Error', 'No valid routes selected.', 'error');
            }
        } else {
            this.showToast('Error', 'Please select at least one order to assign a driver.', 'error');
        }
    }

    openAssignTechnicianModal() {
        if (this.selectedRecordIds.size > 0) {
            const selectedRoutes = [...this.selectedRecordIds].map(recordId => {
                const order = this.orders.find(order => order.Id === recordId);
                return order?.Route__c;
            }).filter(route => route);

            if (selectedRoutes.length > 0) {
                getServiceResources({ routes: selectedRoutes, resourceType: 'Technician' })
                    .then(result => {
                        this.serviceResources = result;
                        this.showTechnicianModal = true;
                    })
                    .catch(error => {
                        this.error = error;
                        this.showToast('Error', 'An error occurred while fetching technicians.', 'error');
                    });
            } else {
                this.showToast('Error', 'No valid routes selected.', 'error');
            }
        } else {
            this.showToast('Error', 'Please select at least one order to assign a technician.', 'error');
        }
    }

    handleServiceResourceChange(event) {
        this.selectedServiceResource = event.target.dataset.id;
    }

    closeDriverModal() {
        this.showDriverModal = false;
        this.selectedServiceResource = null;
    }

    closeTechnicianModal() {
        this.showTechnicianModal = false;
        this.selectedServiceResource = null;
    }

    assignDriver() {
        if (this.selectedServiceResource) {
            const selectedOrders = [...this.selectedRecordIds].map(recordId => {
                return this.orders.find(order => order.Id === recordId);
            }).filter(order => order);

            if (selectedOrders.length > 0) {
                createWorkOrders({ serviceResourceId: this.selectedServiceResource, orders: selectedOrders })
                    .then(() => {
                        this.closeDriverModal();
                        this.selectedRecordIds.clear();
                        this.getFilteredOrders();
                        this.showToast('Success', 'Work orders created for the selected driver.', 'success');
                    })
                    .catch(error => {
                        this.error = error;
                        this.showToast('Error', 'An error occurred while creating work orders.', 'error');
                    });
            } else {
                this.showToast('Error', 'No valid orders selected.', 'error');
            }
        }
    }

    assignTechnician() {
        if (this.selectedServiceResource) {
            const selectedOrders = [...this.selectedRecordIds].map(recordId => {
                return this.orders.find(order => order.Id === recordId);
            }).filter(order => order);

            if (selectedOrders.length > 0) {
                createWorkOrders({ serviceResourceId: this.selectedServiceResource, orders: selectedOrders })
                    .then(() => {
                        this.closeTechnicianModal();
                        this.selectedRecordIds.clear();
                        this.getFilteredOrders();
                        this.showToast('Success', 'Work orders created for the selected technician.', 'success');
                    })
                    .catch(error => {
                        this.error = error;
                        this.showToast('Error', 'An error occurred while creating work orders.', 'error');
                    });
            } else {
                this.showToast('Error', 'No valid orders selected.', 'error');
            }
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}