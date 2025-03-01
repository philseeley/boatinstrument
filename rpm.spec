%define _topdir %(pwd)
%undefine source_date_epoch_from_changelog
%undefine clamp_mtime_to_source_date_epoch

Name:		__NAME__
Version:	__VERSION__
Release:	1%{?dist}
Summary:	A Boat Instrument for displaying SignalK data
Group:		Unspecified
License:	GPL >= v3
BuildArch:	x86_64
BuildRoot:	%{_builddir}
Packager:	Phil Seeley <phil.seeley@gmail.com>
Requires:	gtk3

%description
A Boat Instrument for displaying data in fully configurable Boxes. The data is
received via a subscription to a SignalK server.

The SignalK server should be fed from your boat's NMEA data. The SignalK server
can run on any supported platform, but this is usually a Raspberry Pi running a
marine specific OS build.

%install

mkdir -p %{buildroot}/usr/share/applications

mv %{_sourcedir}/../../build/linux/*/release/bundle %{buildroot}/usr/share/%{name}
cp %{_sourcedir}/../../name.phil.seeley.boatinstrument.desktop %{buildroot}/usr/share/applications

%files
/usr/share/applications/name.phil.seeley.boatinstrument.desktop
/usr/share/%{name}
