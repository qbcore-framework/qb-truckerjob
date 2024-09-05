const TruckingContainer = Vue.createApp({
    data() {
        return this.getInitialState();
    },

    computed: {
    },

    methods: {
        getInitialState() {
            return {
                isTruckingOpen: false,
                page: 'jobs',
                jobs: [
                    t1 = {
                        distance: 917,
                        cargo: 'Beef Pallets',
                        pay: 1500,
                        image: 'trailers2.webp',
                    },
                    t2 = {
                        distance: 1053,
                        cargo: 'Wood Logs',
                        pay: 1834,
                        image: 'trailerlogs.webp'
                    },
                    t3 = {
                        distance: 1452,
                        cargo: 'Steel Beams',
                        pay: 2102,
                        image: 'trailers.webp',
                    },
                    t4 = {
                        distance: 1578,
                        cargo: 'Electronics',
                        pay: 2356,
                        trailersimage: 'trailers.webp',
                    },
                ],
                skillPoints: 3,
                skills: {
                    distance: { level: 4, icon: 'fa-solid fa-road' },
                    cargo: { level:  1, icon: 'fa-solid fa-box' },
                    time: { level: 1, icon: 'fa-solid fa-clock' },
                },
                activeJob: false,
                payPerMeter: 1.7,
                trucks: [
                    { spawnName: 'hauler', name: 'Hauler', price: 0 },
                    { spawnName: 'phantom', name: 'Phantom', price: 25000 },
                ],
                activeTruck: 'hauler',
            }
        },
        openTrucking(data) {
            this.jobs = data.jobs;
            this.page = 'jobs';
            this.skillPoints = data.skillPoints;
            this.skills = data.skills;
            this.activeJob = data.activeJob;
            this.payPerMeter = data.payPerMeter;
            this.trucks = data.trucks;
            this.activeTruck = data.activeTruck;

            this.isTruckingOpen = true;
        },
        async closeTrucking() {
            this.jobs = [];
            this.skills = {};

            await axios.post('https://qb-truckerjob/close', {});
            this.isTruckingOpen = false;
        },
        handleSidebar(element) {
            this.page = element.target.id;
        },
        async acceptJob(jobId) {
            if (!this.canAccept(jobId)) return;
            let response = await axios.post('https://qb-truckerjob/acceptJob', { jobId: jobId });

            console.log(response);
        },
        async cancelJob() {
            await axios.post('https://qb-truckerjob/cancelJob', {});
            this.activeJob = false;
        },
        async upgradeSkill(skill) {
            if (this.skillPoints === 0 && this.skills[skill].level === 4) return;

            let response = await axios.post('https://qb-truckerjob/upgradeSkill', { skill: skill })
            if (!response.data) return;

            this.skills[skill].level++;
            this.skillPoints--;
        },
        async purchaseTruck(truckName) {
            let response = await axios.post('https://qb-truckerjob/purchaseTruck', { truck: truckName });
            if (!response.data?.success) return;

            this.trucks.forEach((truckData, index) => {
                if (response.data.trucks[truckData.spawnName]) {
                    this.trucks[index].owned = true;
                    return;
                }
            })
        },
        async useTruck(truckName) {
            let response = await axios.post('https://qb-truckerjob/useTruck', { truck: truckName });
            if (!response.data?.success) return;
            
            this.activeTruck = response.data.activeTruck;
        },
        canAccept(jobId) {
            if ((this.jobs[jobId].distanceLevel || 1) > this.skills.distance.level) return false;
            if ((this.jobs[jobId].cargoLevel || 1) > this.skills.cargo.level) return false;
            if ((this.jobs[jobId].timeLevel || 1) > this.skills.time.level) return false;

            return true;
        },
    },

    mounted() {
        window.addEventListener('message', (event) => {
            switch(event.data.action) {
                case 'open':
                    this.openTrucking(event.data.data);
                    break;
                case 'close':
                    this.closeTrucking();
                    break;
                default: break;
            }
        });

        window.addEventListener('keyup', (event) => {
            if (event.key === 'Escape') {
                this.closeTrucking();
            }
        });
    },

    beforeUnmount() {
        window.removeEventListener("keyup", () => {});
        window.removeEventListener("message", () => {});
    },
})

TruckingContainer.mount('#app');