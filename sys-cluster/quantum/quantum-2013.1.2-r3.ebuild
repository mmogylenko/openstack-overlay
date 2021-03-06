# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/quantum/quantum-2013.1.2-r2.ebuild,v 1.2 2013/07/24 00:28:42 prometheanfire Exp $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

#restricted due to packages missing and bad depends in the test ==webob-1.0.8   
RESTRICT="test"
DESCRIPTION="Quantum is a virtual network service for Openstack."
HOMEPAGE="https://launchpad.net/quantum"
SRC_URI="http://launchpad.net/${PN}/grizzly/${PV}/+download/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
		test? ( dev-python/cliff[${PYTHON_USEDEP}]
				dev-python/configobj[${PYTHON_USEDEP}] )
				dev-python/coverage[${PYTHON_USEDEP}]
				>=dev-python/mock-1.0[${PYTHON_USEDEP}]
				=dev-python/mox-0.5.3-r1[${PYTHON_USEDEP}]
				dev-python/nose[${PYTHON_USEDEP}]
				dev-python/nosehtmloutput[${PYTHON_USEDEP}]
				dev-python/nosexcover
				dev-python/openstack-nose-plugin[${PYTHON_USEDEP}]
				=dev-python/pep8-1.3.3
				>=dev-python/sphinx-1.1.2[${PYTHON_USEDEP}]
				=dev-python/webtest-1.3.3
				virtual/python-unittest2[${PYTHON_USEDEP}]"
RDEPEND=">=dev-python/pastedeploy-1.5.0-r1[${PYTHON_USEDEP}]
		>=dev-python/alembic-0.4.1[${PYTHON_USEDEP}]
		dev-python/paste[${PYTHON_USEDEP}]
		>=dev-python/routes-1.12.3[${PYTHON_USEDEP}]
		>=dev-python/amqplib-0.6.1-r1[${PYTHON_USEDEP}]
		>=dev-python/anyjson-0.2.4[${PYTHON_USEDEP}]
		>=dev-python/eventlet-0.9.17[${PYTHON_USEDEP}]
		>=dev-python/greenlet-0.3.1[${PYTHON_USEDEP}]
		dev-python/httplib2[${PYTHON_USEDEP}]
		>=dev-python/iso8601-0.1.4[${PYTHON_USEDEP}]
		>=dev-python/kombu-1.0.4-r1[${PYTHON_USEDEP}]
		dev-python/netaddr
		>=dev-python/pyparsing-1.5.6[${PYTHON_USEDEP}]
		<dev-python/pyparsing-2.0[${PYTHON_USEDEP}]
		>=dev-python/python-keystoneclient-0.2.0[${PYTHON_USEDEP}]
		dev-python/python-novaclient[${PYTHON_USEDEP}]
		>=dev-python/python-quantumclient-2.2.0[${PYTHON_USEDEP}]
		<=dev-python/python-quantumclient-3.0.0[${PYTHON_USEDEP}]
		dev-python/pyudev
		>dev-python/sqlalchemy-0.7.8
		<=dev-python/sqlalchemy-0.7.99
		>=dev-python/webob-1.2[${PYTHON_USEDEP}]
		>=dev-python/oslo-config-1.1.0[${PYTHON_USEDEP}]
		virtual/python-argparse[${PYTHON_USEDEP}]
		net-misc/openvswitch"
src_prepare() {
    distutils_src_prepare
    epatch "${FILESDIR}/${P}-metadata.patch"
}

python_install() {
	distutils-r1_python_install
	keepdir /etc/quantum
	insinto /etc/quantum

	doins "etc/api-paste.ini"
	doins "etc/dhcp_agent.ini"
	doins "etc/l3_agent.ini"
	doins "etc/policy.json"
	doins "etc/quantum.conf"
	doins "etc/rootwrap.conf"
	insinto /etc
	doins -r "etc/quantum/"

	newconfd "${FILESDIR}/quantum.confd-2013.1" quantum
	newinitd "${FILESDIR}/quantum.initd-2013.1" quantum

	for function in dhcp-agent l3-agent metadata-agent server openvswitch-agent; do
		dosym /etc/init.d/quantum /etc/init.d/quantum-${function}
	done

	diropts -m 0750
	dodir /var/log/quantum

	# /var/lib/quantum needs to be world-readable for dnsmasq's dhcp (running as nobody)
	diropts -m 0755
	dodir /var/lib/quantum

	#remove the etc stuff from usr...
	rm -R "${D}/usr/etc/"

	insinto "/usr/lib64/python2.7/site-packages/quantum/db/migration/alembic_migrations/"
	doins -r "quantum/db/migration/alembic_migrations/versions"
}
