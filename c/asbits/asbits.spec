Name:           asbits
Version:        1.0.0
Release:        1%{?dist}
Summary:        Displays hexadecimal, decimal and octal numbers in binary

License:        GPLv3+
URL:            https://benjamintoll.com/
Source0:        https://github.com/btoll/tools/blob/master/c/%{name}/%{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  make

%description
Displays hexadecimal, decimal and octal numbers in binary

%prep
%setup -q

%build
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
%make_install

%files
%license LICENSE
%{_bindir}/%{name}
%doc

%changelog
* Mon May 29 2023 Benjamin Toll <ben@benjamintoll.com> - 1.0.0-1
- First asbits package

