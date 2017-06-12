package Algorithm::PID;

use strict;
use warnings;

use IO::File;

sub new {
    my $package = shift;
    my %args = @_;
    die 'filename argument is required' unless ($args{filename});

    my $self = {
        filename => $args{filename}
    };
    bless $self, $package;
    return $self;
}

sub pidfile {
    my $self = shift;
    my $pidfile = $self->{filename};

    if (-e $pidfile) {
        my $fh = IO::File->new($pidfile) or die "Cannot open $pidfile";
        my $pid_running = <$fh>;
        $fh->close();
        
        #Check whether the pid is still running
        if(!$self->isPidRunning($pid_running)) {
            unlink $pidfile or die "Cannot delete PID file $pidfile, reason: $!";
        } else {
            die 'Another process already running, PID ' . $pid_running;
        }
    }

    my $fh = IO::File->new($pidfile, O_CREAT | O_WRONLY | O_TRUNC) or
        die "Cannot create PID file $pidfile, reason: $!";
    $fh->autoflush(1);
    print $fh "$$\n";
    $fh->close();
}

sub isPidRunning {
    my $self = shift;
    my $pid = shift;
    
    $pid = int($pid);
    if($pid) {
        my $running = `ps -p $pid`;
        
        if(!$running) {
           # if ps command failed, try alternative check:
           return 0 unless kill 0, $pid;
        }
        
        #  PID TTY          TIME CMD
        # 4954 pts/0    00:00:00 bash
        if($running !~ /PID/ || $running =~ /\n\s*$pid\s/) {
            #If we didn't find PID, return true too. ps -p command is not supported
            return 1;
        }
    }
    
    return 0;  
}

sub cleanup {
    my $self = shift;
    my $pidfile = $self->{filename};

    my $fh = IO::File->new($pidfile) or die "Cannot open $pidfile";
    my $pid = <$fh>;
    chomp($pid);
    $fh->close();

    if ($$ == $pid) {
        unlink $pidfile or
            die "Cannot delete PID file $pidfile, reason: $!";
    }
}

1;
